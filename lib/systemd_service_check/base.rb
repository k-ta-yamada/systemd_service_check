require 'net/ssh'
require 'thor'
require 'yaml'
require 'json'
require 'pry' # forDebug

# SystemdServiceCheck
module SystemdServiceCheck
  # Base
  class Base
    class InvalidOption < StandardError; end

    Server  = Struct.new(:env, :ip, :user, :options, :services, :hostname)
    Service = Struct.new(:service_name, :load_state, :active_state, :sub_state, :unit_file_state, :type)
    Result  = Struct.new(:server, :services)

    # TODO: systemctl show -p
    STATES    = %w[LoadState ActiveState SubState UnitFileState Type].freeze
    # TODO: setting by yaml
    SHOW_GREP = /env/i

    attr_reader :argv, :env_names, :servers, :target_env, :target_servers, :results

    def initialize(argv, yaml)
      @argv           = argv || []
      @env_names      = []
      @servers        = []
      @target_env     = []
      @target_servers = []
      @results        = []

      raise InvalidOption if yaml.nil? || yaml.empty?
      load_settings(yaml)
      configure_target_servers
      run
    rescue InvalidOption => e
      puts "<#{e}>",
           "  Argument yaml must not be nil or empty.",
           "  yaml.class: [#{yaml.class}]"
      puts "  #{e.backtrace_locations.first}"
    end

    def run
      @results = @target_servers.map { |server| ssh(server) }
    end

    def to_json
      @results.map do |result|
        { server:   result.server.to_h,
          services: result.services.map(&:to_h) }
      end.to_json
    end

    private

    def load_settings(file) # rubocop:disable Metrics/AbcSize
      yaml = JSON.parse(YAML.load_file(File.expand_path(file)).to_json,
                        symbolize_names: true)
      @env_names = yaml[:servers].map { |s| s[:env] }.uniq
      @servers   = yaml[:servers].map do |s|
        raise InvalidOption, "ENV: #{s[:env]}" if [s[:password], s[:key]].all?(nil)
        options = { password: s[:password], keys: [s[:key] || ""] }
        Server.new(s[:env], s[:ip], s[:user], options, s[:services])
      end
    end

    def configure_target_servers
      configure_target_env
      @target_servers = @servers.select { |s| @target_env.include?(s[:env]) }
    end

    def configure_target_env
      @target_env = @env_names & @argv

      # If there is no argument.
      @target_env = @env_names.first if @target_env.empty? && @argv.empty?

      # If there is only one argument and it is `all`.
      @target_env = @env_names if @argv.size == 1 && argv.first == 'all'
    end

    def ssh(server)
      services = []
      Net::SSH.start(server[:ip], server[:user], server[:options]) do |ssh|
        server[:hostname] = ssh.exec!('hostname').chop
        services = server[:services].map { |service_name| systemd(ssh, service_name) }
        # TODO: store in Result object
        # puts ssh.exec!("systemctl list-timers")
      end
      Result.new(server, services)
    end

    def systemd(ssh, service_name)
      states = ssh.exec!("systemctl show #{service_name} -p #{STATES.join(",")}")
                  .split("\n")
                  .map { |v| v.split("=") }
                  .map { |v| [Thor::Util.snake_case(v[0]).to_sym, v[1]] }
                  .each_with_object({}) { |(k, v), memo| memo[k] = v }

      Service.new(
        service_name,
        states[:load_state],
        states[:active_state],
        states[:sub_state],
        states[:unit_file_state] || "n/a",
        states[:type] || "n/a"
      )
    end
  end
end

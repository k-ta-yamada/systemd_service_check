require 'net/ssh'
require 'yaml'
require 'json'
require 'active_support'
require 'active_support/core_ext/string'
require 'pry' # forDebug

# SystemdServiceCheck
module SystemdServiceCheck
  # Base
  class Base
    class InvalidOption < StandardError; end

    Server  = Struct.new(:env, :ip, :user, :options, :services, :hostname)
    Service = Struct.new(*%i[service_name load_state active_state sub_state unit_file_state type])
    Result  = Struct.new(:server, :services)

    ENVS      = %w[dev stg prd].freeze
    # TODO: systemctl show -p
    STATES    = %w[LoadState ActiveState SubState UnitFileState Type].freeze
    # TODO: setting by yaml
    SHOW_GREP = /env/i

    attr_reader :argv, :servers, :target_env, :target_servers, :results

    def initialize(argv: nil, yaml: nil)
      @argv           = argv || []
      @servers        = []
      @target_env     = []
      @target_servers = []
      @results        = []
      load_settings(yaml)
      configure_target_servers
      run
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

    def load_settings(filename) # rubocop:disable Metrics/AbcSize
      yaml = YAML.load_file(filename(filename))
      @servers = yaml[:servers].map do |s|
        raise InvalidOption, "ENV: #{s[:env]}" if [s[:password], s[:key]].all?(nil)
        options = { password: s[:password],
                    keys:     [s[:key] || ""] }
        Server.new(s[:env], s[:ip], s[:user], options, s[:services], s[:hostname])
      end
    end

    def filename(filename)
      if filename.nil?
        File.expand_path('../../systemd_service_check.yml', __FILE__)
      else
        File.expand_path(filename)
      end
    end

    def configure_target_servers
      configure_target_env
      @target_servers = @servers.select { |s| @target_env.include?(s[:env]) }
    end

    def configure_target_env
      @target_env = %w[dev stg prd] & @argv
      # If there is no argument, only `dev` is targeted
      @target_env = %w[dev] if @target_env.empty? && @argv.empty?
      # If there is only one argument and it is `all`, it targets all (dev, stg, prd)
      @target_env = ENVS if @argv.size == 1 && argv.first == 'all'
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
                  .each_with_object({}) { |(k, v), memo| memo[k.underscore.to_sym] = v }

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

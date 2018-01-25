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
    Server  = Struct.new(:env, :ip, :user, :pass, :services, :hostname)
    Service = Struct.new(:service_name, :load_state, :active_state, :sub_state)
    Result  = Struct.new(:server, :services)

    ENVS      = %w[dev stg prd].freeze
    # TODO: systemctl show -p
    STATES    = %w[LoadState ActiveState SubState].freeze
    # TODO: setting by yaml
    SHOW_GREP = /env/i

    attr_reader :argv, :servers, :target_env, :target_servers, :results

    def initialize(argv, yaml)
      @argv     = argv || []
      @servers  = []
      @target_env     = []
      @target_servers = []
      @results = []
      load_settings(yaml)
      configure_target_servers
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

    def load_settings(filename)
      yaml = YAML.load_file(filename(filename))
      @servers = yaml[:servers].map { |s| Server.new(*s.values) }
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
      Net::SSH.start(server[:ip], server[:user], password: server[:pass]) do |ssh|
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
        states[:sub_state]
      )
    end
  end
end

require 'net/ssh'
require 'yaml'
require 'json'
require 'pry'

# SystemdServiceCheck
module SystemdServiceCheck
  # SystemdServiceCheckBase
  class SystemdServiceCheckBase
    Server  = Struct.new(:env, :ip, :user, :pass, :services, :hostname)
    Service = Struct.new(:service_name, :is_active, :is_enabled, :show)
    Result  = Struct.new(:server, :services)

    ENVS      = %w[dev stg prd].freeze
    SHOW_GREP = /env/i

    attr_reader :argv, :servers, :target_env, :target_servers, :results

    def initialize(argv = [])
      @argv     = argv
      @servers  = []
      @target_env     = []
      @target_servers = []
      @results = []
      load_settings
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

    def load_settings
      filename = File.expand_path('../sample.yml', __FILE__)
      yaml     = YAML.load_file(filename)
      @servers = yaml[:servers].map { |s| Server.new(*s.values) }
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
      result = Result.new
      result.server = server

      Net::SSH.start(server[:ip], server[:user], password: server[:pass]) do |ssh|
        result.server[:hostname] = ssh.exec!('hostname').chop
        result.services = server[:services].map { |service| systemd(ssh, service) }
      end

      result
    end

    def systemd(ssh, service)
      is_active  = ssh.exec!("systemctl is-active #{service}.service").chop
      is_enabled = ssh.exec!("systemctl is-enabled #{service}.service").chop
      show = ssh.exec!("systemctl show #{service}.service").split("\n")

      Service.new(service, is_active, is_enabled, show.grep(SHOW_GREP))
    end
  end
end

require "systemd_service_check/version"
require 'systemd_service_check/utils'
require 'systemd_service_check/ssh'

require 'net/ssh'
require 'thor'
require 'awesome_print'
require 'table_print'
require 'yaml'
require 'json'

require 'pry' # forDebug

module SystemdServiceCheck
  # Base
  class Base
    include Utils
    include SSH

    class InvalidOptionError < StandardError; end

    Server = Struct.new(:env, :ip, :user, :options, :services, :hostname) do
      # @return [Array<String, String, Hash>] for Net::SSH.start(*conn_info)
      # @see SSH
      # @see Net::SSH
      def conn_info
        [ip, user, options]
      end
    end

    # TODO: setting by yaml
    SHOW_GREP = /env/i

    attr_reader :argv, :servers, :target_env, :target_servers, :results

    def initialize(argv, yaml)
      raise InvalidOptionError, "Argument `yaml` must not be nil or empty." if blank? yaml

      @argv           = argv || []
      @servers        = servers_from(yaml)
      @target_env     = configure_target_envs(argv, @servers)
      @target_servers = @servers.select { |s| @target_env.include?(s[:env]) }
      @results        = []
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

    def blank?(yaml)
      yaml.nil? || yaml.empty?
    end
  end
end

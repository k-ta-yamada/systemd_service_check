require 'net/ssh'
require 'thor'
require 'awesome_print'
require 'table_print'
require 'yaml'
require 'json'
require 'pry' # forDebug

require "systemd_service_check/version"
require 'systemd_service_check/utils'
require 'systemd_service_check/ssh'

module SystemdServiceCheck
  # Base
  class Base
    include Utils
    include SSH

    attr_reader :envs, :role, :servers, :target_envs, :target_servers, :results

    # @param envs [Arrat<String>]
    # @param yaml [String]
    # @param role [String]
    def initialize(envs, yaml, role = nil)
      raise Utils::InvalidOptionError, "Argument `yaml` must not be blank." if blank? yaml

      @envs           = envs || []
      @role           = role.nil? || role.empty? ? nil : role
      @servers        = servers_from(yaml)
      @target_envs    = configure_target_envs(envs, @servers)
      @target_servers = configure_target_servers(@servers, @target_envs, @role)
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

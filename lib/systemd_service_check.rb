require "systemd_service_check/version"
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
    include SSH

    class InvalidOption < StandardError; end

    Server = Struct.new(:env, :ip, :user, :options, :services, :hostname)

    # TODO: setting by yaml
    SHOW_GREP = /env/i

    attr_reader :argv, :env_names, :servers, :target_env, :target_servers, :results

    def initialize(argv, yaml) # rubocop:disable Metrics/MethodLength
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
  end
end

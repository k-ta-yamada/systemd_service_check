module SystemdServiceCheck
  # Included in: SystemdServiceCheck::Base
  module Utils
    # TODO: systemctl show -p
    PROPERTY = %w[LoadState ActiveState SubState UnitFileState Type].freeze
    PROPERTY_TO_SNAKE_SYM = PROPERTY.map { |v| Thor::Util.snake_case(v).to_sym }

    class InvalidOptionError < StandardError; end

    Server = Struct.new(:env, :role, :ip, :user, :options, :services, :hostname) do
      # @return [Array<String, String, Hash>] for Net::SSH.start(*conn_info)
      # @see SSH
      # @see Net::SSH
      def conn_info
        [ip, user, options]
      end
    end
    Service = Struct.new(:service_name, *PROPERTY_TO_SNAKE_SYM)
    Result  = Struct.new(:server, :services)

    # @param yaml_filename [String] YAML filename with the description of the setting.
    # @return [Array<Utils::Server>]
    def servers_from(yaml_filename) # rubocop:disable Metrics/AbcSize
      yaml = JSON.parse(YAML.load_file(yaml_filename).to_json, symbolize_names: true)

      yaml[:servers].map do |s|
        raise InvalidOptionError, "ENV: #{s[:env]}" if [s[:password], s[:key]].all?(&:nil?) # rubocop:disable Metrics/LineLength
        options = { password: s[:password], keys: [s[:key] || ""] }
        Server.new(s[:env], s[:role], s[:ip], s[:user], options, s[:services])
      end
    end

    # @param argv [Array<String>] Array of ENVs specified with the `ssc check` command.
    # @param servers [Array<Utils::Server>] Server settings.
    # @return [Array<String>] Environment list to be processed.
    def configure_target_envs(argv, servers)
      all_envs = servers.map { |s| s[:env] }.uniq
      target_envs = all_envs & argv

      # If there is no argument.
      target_envs = all_envs.first if target_envs.empty? && argv.empty?
      # If there is only one argument and it is `all`.
      target_envs = all_envs if argv.size == 1 && argv.first == 'all'

      Array(target_envs)
    end

    # @param servers [Array<Utils::Server>]
    # @param target_envs [Array<String>] Environment list to be processed.
    # @return [Array<Utils::Server>]
    def configure_target_servers(servers, target_envs, role)
      servers.select { |s| target_envs.include?(s[:env]) }
             .select { |s| role.nil? || role.empty? ? true : s[:role] == role }
    end
  end
end

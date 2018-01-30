module SystemdServiceCheck
  # Included in: SystemdServiceCheck::Base
  module Utils
    # @param yaml_filename [String] YAML filename with the description of the setting.
    # @return [Array<Base::Server>]
    def servers_from(yaml_filename) # rubocop:disable Metrics/AbcSize
      yaml = JSON.parse(YAML.load_file(yaml_filename).to_json, symbolize_names: true)

      yaml[:servers].map do |s|
        raise InvalidOptionError, "ENV: #{s[:env]}" if [s[:password], s[:key]].all?(nil)
        options = { password: s[:password], keys: [s[:key] || ""] }
        Base::Server.new(s[:env], s[:ip], s[:user], options, s[:services])
      end
    end

    # @param argv [Array<String>] Array of ENVs specified with the `ssc check` command.
    # @param servers [Array<Base::Server>] Server settings.
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
  end
end

# SystemdServiceCheck
module SystemdServiceCheck
  # SSH
  module SSH
    Service = Struct.new(:service_name, :load_state, :active_state, :sub_state, :unit_file_state, :type)
    Result  = Struct.new(:server, :services)

    # TODO: systemctl show -p
    STATES = %w[LoadState ActiveState SubState UnitFileState Type].freeze

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

    def systemd(ssh, service_name) # rubocop:disable Metrics/MethodLength
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

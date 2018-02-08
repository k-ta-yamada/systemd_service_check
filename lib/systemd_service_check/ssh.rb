# SystemdServiceCheck
module SystemdServiceCheck
  # SSH
  module SSH
    # @param server [Utils::Server]
    # @return [Utils::Result]
    def ssh(server)
      services = []
      Net::SSH.start(*server.conn_info) do |ssh|
        server[:hostname] = hostname(ssh)
        services =
          server[:services].map { |service_name| systemctl_show(ssh, service_name) }
        # TODO: store in Result object
        # puts ssh.exec!("systemctl list-timers")
      end
      Utils::Result.new(server, services)
    end

    # @param ssh [Net::SSH::Connection::Session]
    # @return [String]
    def hostname(ssh)
      ssh.exec!('hostname').chomp
    end

    # @param ssh [Net::SSH::Connection::Session]
    # @param service_name [String]
    # @return [Utils::Service]
    def systemctl_show(ssh, service_name)
      prop = ssh.exec!("systemctl show #{service_name} -p #{Utils::PROPERTY.join(",")}")
      Utils::Service.new(service_name, *split_property(prop))
    end

    private

    def split_property(property)
      ret = property.split("\n")
                    .map { |v| v.split("=") }
                    .map { |(v1, v2)| [Thor::Util.snake_case(v1).to_sym, v2] }
                    .each_with_object({}) { |(k, v), memo| memo[k] = v }

      Utils::PROPERTY_TO_SNAKE_SYM.map { |k| ret[k] }
    end
  end
end

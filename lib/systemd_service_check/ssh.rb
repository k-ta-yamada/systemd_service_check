require 'thor'
# SystemdServiceCheck
module SystemdServiceCheck
  # TODO: systemctl show -p
  PROPERTY = %w[LoadState ActiveState SubState UnitFileState Type].freeze

  def self.property_to_sym
    PROPERTY.map { |v| Thor::Util.snake_case(v).to_sym }
  end

  # SSH
  module SSH
    Service = Struct.new(:service_name, *SystemdServiceCheck.property_to_sym)
    Result  = Struct.new(:server, :services)

    # @param server [Base::Server]
    # @return [Result]
    def ssh(server)
      services = []
      # Net::SSH.start(server[:ip], server[:user], server[:options]) do |ssh|
      Net::SSH.start(*server.conn_info) do |ssh|
        server[:hostname] = hostname(ssh)
        services = server[:services].map { |service_name| systemctl_show(ssh, service_name) }
        # TODO: store in Result object
        # puts ssh.exec!("systemctl list-timers")
      end
      Result.new(server, services)
    end

    # @param ssh [Net::SSH::Connection::Session]
    # @return [String]
    def hostname(ssh)
      ssh.exec!('hostname').chomp
    end

    # @param ssh [Net::SSH::Connection::Session]
    # @param service_name [String]
    # @return [Service]
    def systemctl_show(ssh, service_name)
      prop = ssh.exec!("systemctl show #{service_name} --property #{PROPERTY.join(",")}")
      Service.new(service_name, *split_property(prop))
    end

    private

    def split_property(property)
      ret = property.split("\n")
                    .map { |v| v.split("=") }
                    .map { |(v1, v2)| [Thor::Util.snake_case(v1).to_sym, v2] }
                    .each_with_object({}) { |(k, v), memo| memo[k] = v }

      SystemdServiceCheck.property_to_sym.map { |k| ret[k] }
    end

  end
end

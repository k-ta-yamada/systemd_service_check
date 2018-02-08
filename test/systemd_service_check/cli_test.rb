require_relative "../test_helper"
require 'systemd_service_check/cli'
require 'capture_stdout'

module SystemdServiceCheck
  class CLITest < Minitest::Test
    # rubocop:disable Metrics/MethodLength
    def setup
      @ssc = SystemdServiceCheck::CLI.new

      @systemctl_show_sshd =
        "systemctl show sshd.service -p #{Utils::PROPERTY.join(",")}"
      @systemctl_show_rsyslog =
        "systemctl show rsyslog.service -p #{Utils::PROPERTY.join(",")}"

      @property_vals = %w[loaded active running enabled notify]
      @retval_systemctl_show =
        Utils::PROPERTY.zip(@property_vals).map { |kv| kv.join("=") }.join("\n")
      @retval_hostname = "centos7\n"

      options = { password: 'pass' }
      services = %w[sshd.service rsyslog.service]
      @server = Utils::Server.new('test', nil, '127.0.0.1', 'root', options, services)
    end
    # rubocop:enable Metrics/MethodLength

    def test_version
      act = capture_stdout { @ssc.invoke(:version) }.chomp
      exp = SystemdServiceCheck::VERSION
      assert_equal exp, act
    end

    # rubocop:disable Metrics/MethodLength
    def test_check
      ssh_mock = Minitest::Mock.new
      ssh_mock.expect(:exec!, @retval_hostname, ["hostname"])
      ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_sshd])
      ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_rsyslog])

      yaml_file = File.expand_path('./utils_test.yml', File.dirname(__FILE__))
      options = {
        yaml:   yaml_file,
        role:   'ap',
        format: 'json'
      }

      Net::SSH.stub(:start, @server, ssh_mock) do
        act = capture_stdout { @ssc.invoke(:check, ['dev'], options) }.chomp
        # rubocop:disable Metrics/LineLength
        exp = '[{"server":{"env":"dev","role":"ap","ip":"127.0.0.1","user":"root","options":{"password":"vagrant","keys":[""]},"services":["sshd.service","rsyslog.service"],"hostname":"centos7"},"services":[{"service_name":"sshd.service","load_state":"loaded","active_state":"active","sub_state":"running","unit_file_state":"enabled","type":"notify"},{"service_name":"rsyslog.service","load_state":"loaded","active_state":"active","sub_state":"running","unit_file_state":"enabled","type":"notify"}]}]'
        # rubocop:enable Metrics/LineLength
        assert_equal exp, act
      end
      ssh_mock.verify
    end
    # rubocop:enable Metrics/MethodLength
  end
end

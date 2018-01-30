require_relative "../test_helper"
require 'net/ssh/test'

module SystemdServiceCheck
  class SSHTest < Minitest::Test
    include SystemdServiceCheck::SSH

    def setup # rubocop:disable Metrics/AbcSize
      @systemctl_show_sshd =
        "systemctl show sshd.service --property #{PROPERTY.join(",")}"
      @systemctl_show_rsyslog =
        "systemctl show rsyslog.service --property #{PROPERTY.join(",")}"

      @property_vals = %w[loaded active running enabled notify]
      @retval_systemctl_show =
        PROPERTY.zip(@property_vals).map { |kv| kv.join("=") }.join("\n")
      @retval_hostname = "centos7\n"

      # rubocop:disable Security/MarshalLoad, Metrics/LineLength
      @result = Marshal.load(File.read(File.expand_path('./result.dump', File.dirname(__FILE__))))
      @server = Marshal.load(File.read(File.expand_path('./server.dump', File.dirname(__FILE__))))
      # rubocop:enable Security/MarshalLoad, Metrics/LineLength
    end

    def test_ssh
      # ref: How to test a function that yields a block with Minitest and Rspec - Mix & Go
      #      https://mixandgo.com/blog/how-to-test-a-function-that-yields-a-block-with-minitest-and-rspec
      # conn_info = lambda do |host, user, opt|
      #   # We're making sure that the correct arguments are passed along
      #   assert_equal 'mixandgo.com', host
      #   assert_equal 'cezar', user
      #   assert_equal ({ password: 'secret' }), opt
      # end
      ssh_mock = Minitest::Mock.new
      ssh_mock.expect(:exec!, @retval_hostname, ["hostname"])
      ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_sshd])
      ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_rsyslog])

      Net::SSH.stub(:start, @server, ssh_mock) { assert_equal @result, ssh(@server) }
      ssh_mock.verify
    end

    def test_hostname
      ssh_mock = Minitest::Mock.new
      ssh_mock.expect(:exec!, @retval_hostname, ['hostname'])

      assert_equal 'centos7', hostname(ssh_mock)
      ssh_mock.verify
    end

    def test_systemctl_show
      ssh_mock = Minitest::Mock.new
      ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_sshd])

      exp = Service.new(*@property_vals.unshift('sshd.service'))
      act = systemctl_show(ssh_mock, 'sshd.service')
      assert_equal exp, act
      ssh_mock.verify
    end

    def test_split_property
      property = <<~PROPERTY
        LoadState=loaded
        ActiveState=active
        SubState=running
        UnitFileState=enabled
        Type=notify
      PROPERTY

      exp = %w[loaded active running enabled notify]
      act = send(:split_property, property)
      assert_equal exp, act
    end
  end # of SSHTest
end # of SystemdServiceCheck

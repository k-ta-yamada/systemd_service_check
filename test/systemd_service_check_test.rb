# require "test_helper"
require_relative "./test_helper"

class SystemdServiceCheckTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil SystemdServiceCheck::VERSION
  end

  def test_self_property_to_sym
    exp = %i[load_state active_state sub_state unit_file_state type]
    act = SystemdServiceCheck.property_to_sym
    assert_equal exp, act
  end

  class BaseTest < Minitest::Test
    def setup
      @yaml = File.expand_path('../systemd_service_check.sample.yml', File.dirname(__FILE__))

      @systemctl_show_sshd =
      "systemctl show sshd.service --property #{SystemdServiceCheck::PROPERTY.join(",")}"
      @systemctl_show_rsyslog =
        "systemctl show rsyslog.service --property #{SystemdServiceCheck::PROPERTY.join(",")}"

      @property_vals = %w[loaded active running enabled notify]
      @retval_systemctl_show =
        SystemdServiceCheck::PROPERTY.zip(@property_vals).map { |kv| kv.join("=") }.join("\n")
      @retval_hostname = "centos7\n"
      # rubocop:disable Security/MarshalLoad, Metrics/LineLength
      @result = Marshal.load(File.read(File.expand_path('./systemd_service_check/result.dump', File.dirname(__FILE__))))
      @server = Marshal.load(File.read(File.expand_path('./systemd_service_check/server.dump', File.dirname(__FILE__))))
      # rubocop:enable Security/MarshalLoad, Metrics/LineLength
    end

    def test_init_error
      # skip
      assert_raises SystemdServiceCheck::Base::InvalidOptionError do
        SystemdServiceCheck::Base.new(nil, nil)
      end
      assert_raises SystemdServiceCheck::Base::InvalidOptionError do
        SystemdServiceCheck::Base.new(nil, "")
      end
      # binding.pry
      # ssh_mock = Minitest::Mock.new
      # ssh_mock.expect(:exec!, @retval_hostname, ["hostname"])
      # ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_sshd])
      # ssh_mock.expect(:exec!, @retval_systemctl_show, [@systemctl_show_rsyslog])
      # Net::SSH.stub(:start, @server, ssh_mock) do
      #   # assert_equal @result, ssh(@server)
      #   ssc = SystemdServiceCheck::Base.new([], @yaml)
      #   # ssc
      #   assert ssc
      # end
      # ssh_mock.verify
    end

    def test_configure_target_envs
      skip
      assert false
    end

    def test_run
      skip
    end

    def test_to_json
      skip
    end
  end
end

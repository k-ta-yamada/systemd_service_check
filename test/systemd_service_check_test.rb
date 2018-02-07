# require "test_helper"
require_relative "./test_helper"

module SystemdServiceCheck
  class BaseTest < Minitest::Test
    # rubocop:disable Metrics/LineLength
    def setup
      @yaml = File.expand_path('../systemd_service_check.sample.yml', File.dirname(__FILE__))

      @systemctl_show_sshd =
        "systemctl show sshd.service -p #{Utils::PROPERTY.join(",")}"
      @systemctl_show_rsyslog =
        "systemctl show rsyslog.service -p #{Utils::PROPERTY.join(",")}"

      @property_vals = %w[loaded active running enabled notify]
      @retval_systemctl_show =
        Utils::PROPERTY.zip(@property_vals).map { |kv| kv.join("=") }.join("\n")
      @retval_hostname = "centos7\n"
    end
    # rubocop:enable Metrics/LineLength

    def test_init_error
      # skip
      assert_raises Utils::InvalidOptionError do
        SystemdServiceCheck::Base.new(nil, nil, nil)
      end
      assert_raises Utils::InvalidOptionError do
        SystemdServiceCheck::Base.new(nil, "", nil)
      end
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

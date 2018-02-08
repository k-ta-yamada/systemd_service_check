# require "test_helper"
require_relative "./test_helper"

module SystemdServiceCheck
  class BaseTest < Minitest::Test
    def test_init_error
      # skip
      assert_raises Utils::InvalidOptionError do
        Base.new(nil, nil, nil)
      end
      assert_raises Utils::InvalidOptionError do
        Base.new(nil, "", nil)
      end
    end

    def test_initialize
      yaml_file = File.expand_path('./systemd_service_check/utils_test.yml', File.dirname(__FILE__))
      act = Base.new(['dev'], yaml_file, nil)
      assert act.is_a?(Base)
    end

    def test_run
      skip
    end

    def test_to_json
      skip
    end
  end
end

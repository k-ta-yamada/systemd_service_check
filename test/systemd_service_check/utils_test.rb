require_relative "../test_helper"
require 'net/ssh/test'

module SystemdServiceCheck
  class UtilsTest < Minitest::Test
    include Utils

    def test_servers_from
      yaml_file = File.expand_path('./utils_test.yml', File.dirname(__FILE__))
      act = servers_from(yaml_file)

      assert(act.size == 3)
      assert(act.all? { |v| v.is_a?(Base::Server) })
    end

    def test_configure_target_envs
      envs = %w[dev stg prd]
      servers = envs.map { |env| Base::Server.new(env) }

      assert_equal [],                configure_target_envs([], [])
      assert_equal Array(envs.first), configure_target_envs([], servers)
      assert_equal envs,              configure_target_envs(%w[all], servers)
    end
  end
end

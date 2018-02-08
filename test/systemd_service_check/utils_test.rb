require_relative "../test_helper"

module SystemdServiceCheck
  class UtilsTest < Minitest::Test
    include Utils

    def test_servers_from
      yaml_file = File.expand_path('./utils_test.yml', File.dirname(__FILE__))
      act = servers_from(yaml_file)

      assert(act.size == 3)
      assert(act.all? { |v| v.is_a?(Server) })
    end

    def test_configure_target_envs
      envs = %w[dev stg prd]
      servers = envs.map { |env| Server.new(env) }

      assert_equal [],                configure_target_envs([], [])
      assert_equal Array(envs.first), configure_target_envs([], servers)
      assert_equal envs,              configure_target_envs(%w[all], servers)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def test_configure_target_servers
      envs    = %w[dev stg prd]
      roles   = [nil, 'ap', 'db']
      servers = envs.product(roles).map { |env, role| Server.new(env, role) }
      assert_equal 9, servers.size

      none_env = configure_target_servers(servers, [], nil)
      assert_equal 0, none_env.size

      all_role_of_dev = configure_target_servers(servers, %w[dev], nil)
      assert_equal 3, all_role_of_dev.size
      assert all_role_of_dev.all?(Server)

      ap_roll_of_dev = configure_target_servers(servers, %w[dev], 'ap')
      assert_equal 1, ap_roll_of_dev.size
      assert ap_roll_of_dev.all?(Server)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end

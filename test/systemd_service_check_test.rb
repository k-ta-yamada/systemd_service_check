require "test_helper"

class SystemdServiceCheckTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SystemdServiceCheck::VERSION
  end

  def test_it_does_something_useful
    skip
    assert false
  end
end

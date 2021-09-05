
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "systemd_service_check/version"

Gem::Specification.new do |spec|
  spec.name          = "systemd_service_check"
  spec.version       = SystemdServiceCheck::VERSION
  spec.authors       = ["k-ta-yamada"]
  spec.email         = ["key.luvless@gmail.com"]

  spec.required_ruby_version = '>= 2.6.0'

  spec.summary       = 'This gem provide `ssc` command to check multiple `systemd service` etc on multiple remote servers using net-ssh.'
  spec.description   = 'This gem provide `ssc` command to check multiple `systemd service` etc on multiple remote servers using net-ssh.'
  spec.homepage      = "https://github.com/k-ta-yamada/systemd_service_check"
  spec.license       = "MIT"

  # # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables   = ['ssc']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  # https://github.com/codeclimate/test-reporter/issues/413
  spec.add_development_dependency 'simplecov', '= 0.17'

  spec.add_development_dependency 'capture_stdout'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'pry-theme'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'awesome_print'
  spec.add_dependency 'net-ssh'
  spec.add_dependency 'pry'
  spec.add_dependency 'table_print'
  spec.add_dependency 'thor'
end

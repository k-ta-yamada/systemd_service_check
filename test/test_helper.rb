$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "systemd_service_check"

require "minitest/autorun"

require "minitest/reporters"
Minitest::Reporters.use! [
  # Minitest::Reporters::DefaultReporter.new,  # => Redgreen-capable version of standard Minitest reporter
  Minitest::Reporters::SpecReporter.new,     # => Turn-like output that reads like a spec
  # Minitest::Reporters::ProgressReporter.new, # => Fuubar-like output with a progress bar
  # Minitest::Reporters::RubyMateReporter.new, # => Simple reporter designed for RubyMate
  # Minitest::Reporters::RubyMineReporter.new, # => Reporter designed for RubyMine IDE and TeamCity CI server
  # Minitest::Reporters::JUnitReporter.new,    # => JUnit test reporter designed for JetBrains TeamCity
  # Minitest::Reporters::MeanTimeReporter.new, # => Produces a report summary showing the slowest running tests
  # Minitest::Reporters::HtmlReporter.new,     # => Generates an HTML report of the test results
]

require "pry" # forDebug

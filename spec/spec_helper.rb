require 'bundler/setup'
require 'acts_as_mentionable'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

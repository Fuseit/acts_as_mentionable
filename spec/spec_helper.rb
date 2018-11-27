require 'bundler/setup'
require 'rspec/its'
require 'database_cleaner'
require 'acts_as_mentionable'

begin
  require 'pry-byebug'
rescue LoadError
end

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

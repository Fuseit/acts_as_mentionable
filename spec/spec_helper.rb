require 'bundler/setup'
require 'rspec/its'
require 'database_cleaner'
require 'acts_as_mentionable'

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

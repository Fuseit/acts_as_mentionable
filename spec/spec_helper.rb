$LOAD_PATH << '.' unless $LOAD_PATH.include?('.')
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

# require 'logger'
# require 'rails'
require 'rspec/its'
require 'database_cleaner'
require 'bundler/setup'
require 'acts_as_mentionable'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|

  config.example_status_persistence_file_path = ".rspec_status"
  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

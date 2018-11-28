ActiveRecord::Migration.verbose = false
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

require File.dirname(__FILE__) + '/../internal/db/schema.rb'

Dir[File.dirname(__FILE__) + '/../internal/app/models/*.rb'].each { |file| require file }

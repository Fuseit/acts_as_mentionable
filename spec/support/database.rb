ActiveRecord::Migration.verbose = false
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

require File.dirname(__FILE__) + '/../internal/db_schema.rb'

Dir[File.dirname(__FILE__) + '/../internal/models/*.rb'].each { |file| require file }


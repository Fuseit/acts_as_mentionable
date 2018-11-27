RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  config.around :each do |example|
    if example.metadata[:skip_transactions]
      example.run
    else
      DatabaseCleaner.cleaning(&example)
    end
  end
end

require 'active_record'
require 'acts_as_mentionable/version'

begin
  require 'rails/engine'
  require 'acts_as_mentionable/engine'
rescue LoadError
  puts 'Rails enviroment is not detected - database migrations are not appended.'
end

module ActsAsMentionable
  extend ActiveSupport::Autoload

  autoload :Mention
  autoload :MentionablesManipulator
  autoload :MentionsUpdater
  autoload :EventPublisher
  autoload :Mentionable
  autoload :Mentioner
  autoload :RetrievePolymorphic
  autoload :TransactionCallbacks
  autoload :ActiveRecordMethods

  def self.setup
    @configuration ||= Configuration.new
    yield @configuration if block_given?
  end

  def self.respond_to_missing? method_name, include_private = false
    @configuration.respond_to?(method_name) || super
  end

  def self.method_missing method_name, *args, &block
    if @configuration.respond_to?(method_name)
      @configuration.send(method_name, *args, &block)
    else
      super
    end
  end

  class Configuration
    attr_accessor \
      :mentions_table,
      :event_publisher_class

    def initialize
      @mentions_table = :acts_as_mentionable_mentions
      @event_publisher_class = EventPublisher
    end
  end

  setup
end

ActiveSupport.on_load :active_record do
  include ActsAsMentionable::ActiveRecordMethods
end

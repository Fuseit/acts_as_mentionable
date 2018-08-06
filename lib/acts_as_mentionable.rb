require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'

begin
  require 'acts_as_mentionable/engine'
  require 'acts_as_mentionable/configuration'
rescue LoadError
end

module ActsAsMentionable
  extend ActiveSupport::Autoload

  # Autoloaders
  autoload :VERSION

  class << self
    def setup
      @configuration ||= Configuration.new
      yield @configuration if block_given?
    end

    def method_missing(method_name, *args, &block)
      if @configuration.respond_to?(method_name)
        @configuration.send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      @configuration.respond_to?(method_name)
    end

    def glue
      # implement me
    end
  end

  setup
end

ActiveSupport.on_load(:active_record) do
  # extend ActsAsMentionable::Mentionable
  # include ActsAsMentionable::Mentioner
end

ActiveSupport.on_load(:action_view) do
  # include ActsAsMentionable::FormHelper ... etc
end

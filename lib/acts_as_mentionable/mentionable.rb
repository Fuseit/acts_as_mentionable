module ActsAsMentionable
  module Mentionable
    extend ActiveSupport::Concern

    included do
      has_many :mentions,
        as: :mentionable,
        dependent: :delete_all,
        class_name: '::ActsAsMentionable::Mention'

      ::ActsAsMentionable::EventPublisher.subscribe self, prefix: true
    end

    def mentionable?
      true
    end

    def mentioners
      RetrievePolymorphic.new(mentions, :mentioner).call
    end
  end
end

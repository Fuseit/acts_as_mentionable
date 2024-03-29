module ActsAsMentionable
  module Mentionable
    extend ActiveSupport::Concern

    included do
      has_many :mentions,
        as: :mentionable,
        class_name: '::ActsAsMentionable::Mention'
    end

    def mentionable?
      true
    end

    def mentioners
      RetrievePolymorphic.new(mentions, :mentioner).call
    end
  end
end

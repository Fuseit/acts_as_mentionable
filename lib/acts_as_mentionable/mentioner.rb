module ActsAsMentionable
  module Mentioner
    extend ActiveSupport::Concern

    included do
      has_many :mentions,
        as: :mentioner,
        dependent: :delete_all,
        class_name: '::ActsAsMentionable::Mention'
    end

    def mentioner?
      true
    end

    def mentionables
      RetrievePolymorphic.new(mentions, :mentionable).call
    end
  end
end

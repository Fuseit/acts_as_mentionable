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

    def mention *mentionables, save: false
      mentionables_manipulator.add(*mentionables)
      save_mentions if save
    end

    def unmention *mentionables, save: false
      mentionables_manipulator.remove(*mentionables)
      save_mentions if save
    end

    def replace_mentionables *mentionables, save: false
      mentionables_manipulator.replace(*mentionables)
      save_mentions if save
    end

    def save_mentions
      return false unless mentionables_manipulator.changed?

      MentionsUpdater.new(self, mentionables_manipulator.changes).call
      TransactionCallbacks.on_committed { mentionables_manipulator.fix_changes! }

      true
    end

    private

      def mentionables_manipulator
        @mentionables_manipulator ||= MentionablesManipulator.new mentionables
      end
  end
end

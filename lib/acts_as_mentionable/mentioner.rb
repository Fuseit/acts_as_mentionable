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

      MentionsUpdater.new(self, mentionables_manipulator.changes).call do
        fix_mentionables_changes!
      end

      true
    end

    private

      def mentionables_manipulator
        @mentionables_manipulator ||= MentionablesManipulator.new mentionables
      end

      def refresh_mentionables_manipulator!
        remove_instance_variable :@mentionables_manipulator
      end

      def fix_mentionables_changes!
        mentionables_manipulator.fix_changes!

        TransactionCallbacks.on_rolled_back do
          current = mentionables_manipulator.current
          refresh_mentionables_manipulator!
          mentionables_manipulator.replace current
        end
      end
  end
end

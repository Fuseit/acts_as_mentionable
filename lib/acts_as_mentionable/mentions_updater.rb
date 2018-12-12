module ActsAsMentionable
  class MentionsUpdater
    attr_reader :mentioner, :changes

    def initialize mentioner, changes
      @mentioner = mentioner
      @changes = changes
    end

    def call
      Mention.transaction do
        remove_old_mentionables
        add_new_mentionables
        invoke_mentions_updated_callback
        yield if block_given?
      end
    end

    private

      def remove_old_mentionables
        Mention.remove_mentionables_for_mentioner mentioner, changes[:removed] unless changes[:removed].empty?
      end

      def add_new_mentionables
        Mention.add_mentionables_for_mentioner mentioner, changes[:added] unless changes[:added].empty?
      end

      def invoke_mentions_updated_callback
        TransactionCallbacks.on_committed do
          ActsAsMentionable.mentions_updated_callback.call mentioner, changes
        end
      end
  end
end

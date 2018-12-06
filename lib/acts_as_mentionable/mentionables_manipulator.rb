module ActsAsMentionable
  class MentionablesManipulator
    attr_reader :previous_set, :current_set

    def initialize mentionables
      @previous_set = mentionables.to_set
      @current_set = mentionables.to_set
    end

    def add *mentionables
      current_set.merge prepare_mentionables(mentionables)
      self
    end

    def remove *mentionables
      current_set.subtract prepare_mentionables(mentionables)
      self
    end

    def replace *mentionables
      current_set.replace prepare_mentionables(mentionables)
      self
    end

    def fix_changes!
      previous_set.replace current_set
      self
    end

    def changes
      {
        changed: changed?,
        added: added,
        removed: removed,
        previous: previous,
        current: current
      }
    end

    def changed?
      current_set != previous_set
    end

    def added
      (current_set - previous_set).to_a
    end

    def removed
      (previous_set - current_set).to_a
    end

    def previous
      previous_set.to_a
    end

    def current
      current_set.to_a
    end

    private

      def prepare_mentionables mentionables
        mentionables.flatten
      end
  end
end

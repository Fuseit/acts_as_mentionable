module ActsAsMentionable
  module ActiveRecordMethods
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_mentionable
        include ActsAsMentionable::Mentionable
      end

      def acts_as_mentioner
        include ActsAsMentionable::Mentioner
      end
    end

    def mentionable?
      false
    end

    def mentioner?
      false
    end
  end
end

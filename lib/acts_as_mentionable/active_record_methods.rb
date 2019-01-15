module ActsAsMentionable
  module ActiveRecordMethods
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_mentionable mentionable_field
        class_eval do
          cattr_reader :mentionable_field

          class_variable_set('@@mentionable_field', mentionable_field)
        end
        include ActsAsMentionable::Mentionable
      end

      def acts_as_mentioner mention_field
        class_eval do
          cattr_reader :mention_field, :mention_parsed_field

          class_variable_set('@@mention_field', mention_field)
          class_variable_set('@@mention_parsed_field', "parsed_#{mention_field}".to_sym)
        end
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

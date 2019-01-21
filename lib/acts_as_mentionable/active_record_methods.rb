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

          after_save :retrieve_mentions_callback, if: :need_retrieve_mentions? if self <= ActiveRecord::Base

          define_method(:need_retrieve_mentions?) { send "parsed_#{self.class.mention_field}_changed?" }

          define_method(:retrieve_mentions_callback) { nil }

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

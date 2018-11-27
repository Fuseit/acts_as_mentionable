# == Schema Information
#
# Table name: mentions
#
#  id               :integer          not null, primary key
#  mentionable_id   :integer          not null
#  mentionable_type :string(255)      not null
#  mentioner_id     :integer          not null
#  mentioner_type   :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

module ActsAsMentionable
  class Mention < ActiveRecord::Base
    self.table_name = ActsAsMentionable.mentions_table

    belongs_to :mentioner, polymorphic: true
    belongs_to :mentionable, polymorphic: true

    scope :by_mentioners, ->(mentioners) { where mentioner: mentioners }
    scope :by_mentionables, ->(mentionables) { where mentionable: mentionables }

    validate :validate_mentioner
    validate :validate_mentionable

    def self.remove_mentionables_for_mentioner mentioner, mentionables
      by_mentioners(mentioner).by_mentionables(mentionables).delete_all
    end

    def self.add_mentionables_for_mentioner mentioner, mentionables
      attributes_list = Array(mentionables).map { |mentionable| { mentionable: mentionable } }
      by_mentioners(mentioner).create! attributes_list
    end

    private

      def validate_mentioner
        errors.add :mentioner, :invalid unless mentioner.respond_to?(:mentioner?) && mentioner.mentioner?
      end

      def validate_mentionable
        errors.add :mentionable, :invalid unless mentionable.respond_to?(:mentionable?) && mentionable.mentionable?
      end
  end
end

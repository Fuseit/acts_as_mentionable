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
  class Mention < ::ActiveRecord::Base
    self.table_name = ActsAsMentionable.mentions_table
  end
end

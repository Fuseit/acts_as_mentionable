require 'acts_as_mentionable'

class ActsAsMentionableMigration < ActiveRecord::Migration
  def self.change
    create_table ActsAsMentionable.mentions_table do |t|
      t.reference :mentionable, index: { name: 'mentions_mentionable_idx' }
      t.reference :mentioner, index: { name: 'mentions_mentioner_idx' }
      t.timestamps
    end

    add_index ActsAsMentionable.mentions_table,
      %i[mentionable_id mentionable_type mentioner_id mentioner_type],
      name: 'mentions_mentionable_mentioner_idx',
      unique: true
  end
end

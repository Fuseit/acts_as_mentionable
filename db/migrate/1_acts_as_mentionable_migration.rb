class ActsAsTaggableOnMigration < ActiveRecord::Migration

  def self.change
    create_table :acts_as_mentionable_mentions do |t|
      t.reference :mentionable, index: { name: "mentions_mentionable_idx" }
      t.reference :mentioner, index: { name: 'mentions_mentioner_idx' }
      t.timestamps
    end

    add_index :acts_as_mentionable_mentions, [:mentionable_id, :mentionable_type, :mentioner_id, :mentioner_type], name: "mentions_mentionable_mentioner_idx", unique: true
  end
end

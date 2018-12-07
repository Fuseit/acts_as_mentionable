if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class ActsAsMentionableMigration < ActiveRecord::Migration[4.2]; end
else
  class ActsAsMentionableMigration < ActiveRecord::Migration; end
end

ActsAsMentionableMigration.class_eval do
  def change
    create_table ActsAsMentionable.mentions_table do |t|
      t.references :mentionable, polymorphic: true, index: { name: 'mentions_mentionable_idx' }
      t.references :mentioner, polymorphic: true, index: { name: 'mentions_mentioner_idx' }
      t.timestamps
    end

    add_index ActsAsMentionable.mentions_table,
      %i[mentionable_id mentionable_type mentioner_id mentioner_type],
      name: 'mentions_mentionable_mentioner_idx',
      unique: true
  end
end

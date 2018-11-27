ActiveRecord::Schema.define version: 0 do
  create_table ActsAsMentionable.mentions_table do |t|
    t.references :mentionee, polymorphic: true, index: false
    t.references :mentioner, polymorphic: true, index: false
    t.timestamps null: false
  end

  add_index ActsAsMentionable.mentions_table, [:mentionee_id, :mentionee_type], name: "mentions_mentionee_idx"
  add_index ActsAsMentionable.mentions_table, [:mentioner_id, :mentioner_type], name: "mentions_mentioner_idx"
  add_index ActsAsMentionable.mentions_table, [:mentionee_id, :mentionee_type, :mentioner_id, :mentioner_type], name: "mentions_mentionee_mentioner_idx", unique: true

  create_table :dummy_mentionees do |t|
    t.timestamps null: false
  end

  create_table :dummy_mentioners do |t|
    t.timestamps null: false
  end

end

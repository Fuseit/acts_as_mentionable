ActiveRecord::Schema.define version: 0 do
  create_table ActsAsMentionable.mentions_table do |t|
    t.belongs_to :mentionable,
      polymorphic: true,
      index: { name: :index_mentions_on_mentionable },
      null: false

    t.belongs_to :mentioner,
      polymorphic: true,
      index: { name: :index_mentions_on_mentioner },
      null: false

    t.timestamps null: false
  end

  add_index ActsAsMentionable.mentions_table,
    %i(mentionable_type mentionable_id mentioner_type mentioner_id),
    unique: true,
    name: :index_mentions_on_mentionable_and_mentioner

  create_table :mentionables do |t|
    t.timestamps null: false
  end

  create_table :mentioners do |t|
    t.timestamps null: false
  end

  create_table :dummies do |t|
    t.timestamps null: false
  end
end

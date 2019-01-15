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
    %i[mentionable_type mentionable_id mentioner_type mentioner_id],
    unique: true,
    name: :index_mentions_on_mentionable_and_mentioner

  create_table :mentionable_models do |t|
    t.string :username
    t.timestamps null: false
  end

  create_table :mentioner_models do |t|
    t.text :body
    t.text :parsed_body
    t.timestamps null: false
  end

  create_table :plain_models do |t|
    t.timestamps null: false
  end
end

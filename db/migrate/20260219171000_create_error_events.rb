class CreateErrorEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :error_events do |t|
      t.string :classification, null: false
      t.string :error_class, null: false
      t.string :message, null: false
      t.string :request_id
      t.string :path
      t.string :http_method
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :error_events, [ :classification, :created_at ]
    add_index :error_events, :request_id
  end
end

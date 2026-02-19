class CreateActivityEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_events do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :event_type, null: false
      t.references :subject, polymorphic: true, null: false
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :activity_events, [ :organization_id, :created_at ]
    add_index :activity_events, [ :subject_type, :subject_id, :created_at ]
  end
end

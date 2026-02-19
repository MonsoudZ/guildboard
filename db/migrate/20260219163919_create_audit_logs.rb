class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :actor, null: true, foreign_key: { to_table: :users }
      t.references :organization, null: true, foreign_key: true
      t.string :action, null: false
      t.references :auditable, polymorphic: true, null: true
      t.json :metadata, null: false, default: {}
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :audit_logs, [ :action, :created_at ]
    add_index :audit_logs, [ :organization_id, :created_at ]
  end
end

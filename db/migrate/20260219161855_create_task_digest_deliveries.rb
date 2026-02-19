class CreateTaskDigestDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :task_digest_deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :delivered_on, null: false

      t.timestamps
    end

    add_index :task_digest_deliveries, [ :user_id, :delivered_on ], unique: true
  end
end

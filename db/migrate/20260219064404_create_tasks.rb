class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.date :due_on

      t.timestamps
    end

    add_index :tasks, [ :project_id, :status ]
    add_index :tasks, [ :assignee_id, :status ]
    add_index :tasks, :due_on
  end
end

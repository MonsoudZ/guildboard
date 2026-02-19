class AddSoftDeleteToProjectTaskAndComment < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :deleted_at, :datetime
    add_column :tasks, :deleted_at, :datetime
    add_column :task_comments, :deleted_at, :datetime

    add_index :projects, :deleted_at
    add_index :tasks, :deleted_at
    add_index :task_comments, :deleted_at
  end
end

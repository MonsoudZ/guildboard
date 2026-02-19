class AddLockVersionToProjectsAndTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :lock_version, :integer, null: false, default: 0
    add_column :tasks, :lock_version, :integer, null: false, default: 0
  end
end

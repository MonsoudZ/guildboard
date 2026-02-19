require "test_helper"

class SoftDeleteTest < ActiveSupport::TestCase
  test "soft deleted project is hidden by default and recoverable" do
    project = projects(:core)
    project.soft_delete!

    assert_nil Project.find_by(id: project.id)
    assert Project.with_deleted.find(project.id).deleted?

    Project.with_deleted.find(project.id).restore!
    assert Project.find_by(id: project.id)
  end

  test "soft deleted task is hidden by default and recoverable" do
    task = tasks(:backlog)
    task.soft_delete!

    assert_nil Task.find_by(id: task.id)
    assert Task.with_deleted.find(task.id).deleted?

    Task.with_deleted.find(task.id).restore!
    assert Task.find_by(id: task.id)
  end

  test "soft deleted task comment is hidden by default and recoverable" do
    comment = task_comments(:first_note)
    comment.soft_delete!

    assert_nil TaskComment.find_by(id: comment.id)
    assert TaskComment.with_deleted.find(comment.id).deleted?

    TaskComment.with_deleted.find(comment.id).restore!
    assert TaskComment.find_by(id: comment.id)
  end
end

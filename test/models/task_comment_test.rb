require "test_helper"

class TaskCommentTest < ActiveSupport::TestCase
  test "requires author membership in task organization" do
    comment = TaskComment.new(task: tasks(:backlog), author: users(:charlie), body: "Outsider comment")

    assert_not comment.valid?
    assert_includes comment.errors[:author], "must be a member of the task organization"
  end

  test "rejects comment for archived project task" do
    comment = TaskComment.new(task: tasks(:legacy_task), author: users(:alice), body: "Cannot post here")

    assert_not comment.valid?
    assert_includes comment.errors[:task], "belongs to an archived project"
  end
end

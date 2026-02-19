require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "requires assignee membership in project organization" do
    task = Task.new(
      project: projects(:core),
      creator: users(:alice),
      assignee: users(:charlie),
      title: "Invalid assignee",
      status: :todo,
      priority: :medium
    )

    assert_not task.valid?
    assert_includes task.errors[:assignee], "must be a member of the project organization"
  end

  test "cannot write task on archived project" do
    task = Task.new(
      project: projects(:legacy),
      creator: users(:alice),
      assignee: users(:bob),
      title: "Archived task write",
      status: :todo,
      priority: :low
    )

    assert_not task.valid?
    assert_includes task.errors[:project], "is archived and read-only"
  end

  test "allows valid status transition" do
    task = tasks(:auth_review)
    task.status = :in_progress

    assert task.valid?
  end

  test "rejects invalid status transition" do
    task = tasks(:backlog)
    task.status = :todo

    assert_not task.valid?
    assert_includes task.errors[:status], "cannot transition from In progress to Todo"
  end
end

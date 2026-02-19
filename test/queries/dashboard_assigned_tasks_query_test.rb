require "test_helper"

class DashboardAssignedTasksQueryTest < ActiveSupport::TestCase
  test "returns open assigned tasks ordered by recency" do
    tasks = DashboardAssignedTasksQuery.call(user: users(:bob), limit: 10)

    assert_includes tasks, tasks(:backlog)
    assert_not_includes tasks, tasks(:legacy_task)
  end
end

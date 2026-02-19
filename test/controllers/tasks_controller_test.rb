require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "member can create task" do
    sign_in_as(users(:alice))

    assert_difference [ "Task.count", "ActivityEvent.count" ] do
      post organization_project_tasks_url(organizations(:acme), projects(:core)), params: {
        task: {
          title: "Publish sprint plan",
          description: "Share scope with stakeholders",
          status: :todo,
          priority: :high,
          assignee_id: users(:bob).id,
          due_on: "2026-03-05"
        }
      }
    end

    created = Task.find_by!(title: "Publish sprint plan")
    assert_equal users(:alice), created.creator
    assert_redirected_to organization_project_task_url(organizations(:acme), projects(:core), created)
  end

  test "non member cannot create task" do
    sign_in_as(users(:charlie))

    assert_no_difference "Task.count" do
      post organization_project_tasks_url(organizations(:acme), projects(:core)), params: {
        task: {
          title: "Unauthorized task",
          description: "Should fail",
          status: :todo,
          priority: :low,
          assignee_id: users(:alice).id
        }
      }
    end

    assert_redirected_to organizations_url
  end

  test "cannot create task on archived project" do
    sign_in_as(users(:alice))

    assert_no_difference "Task.count" do
      post organization_project_tasks_url(organizations(:acme), projects(:legacy)), params: {
        task: {
          title: "Archived write",
          description: "Should fail",
          status: :todo,
          priority: :low,
          assignee_id: users(:bob).id
        }
      }
    end

    assert_redirected_to organization_project_url(organizations(:acme), projects(:legacy))
  end

  test "can view task on archived project" do
    sign_in_as(users(:alice))
    get organization_project_task_url(organizations(:acme), projects(:legacy), tasks(:legacy_task))

    assert_response :success
  end

  test "updating task creates activity event" do
    sign_in_as(users(:alice))

    assert_difference "ActivityEvent.count", 1 do
      patch organization_project_task_url(organizations(:acme), projects(:core), tasks(:auth_review)), params: {
        task: {
          title: "Review session security",
          description: "Updated plan",
          status: :in_progress,
          priority: :high,
          assignee_id: users(:bob).id,
          due_on: "2026-03-15"
        }
      }
    end

    assert_redirected_to organization_project_task_url(organizations(:acme), projects(:core), tasks(:auth_review))
  end

  test "stale task update is rejected" do
    sign_in_as(users(:alice))
    stale_lock_version = tasks(:auth_review).lock_version
    tasks(:auth_review).update!(description: "Competing task update")

    patch organization_project_task_url(organizations(:acme), projects(:core), tasks(:auth_review)), params: {
      task: { description: "My stale task update", lock_version: stale_lock_version }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "Task was changed by another user. Reload and try again."
  end

  test "soft deleted task is hidden until restored" do
    sign_in_as(users(:alice))
    task = tasks(:backlog)
    task.soft_delete!

    get organization_project_task_url(organizations(:acme), projects(:core), task)
    assert_response :not_found

    Task.with_deleted.find(task.id).restore!
    get organization_project_task_url(organizations(:acme), projects(:core), task)
    assert_response :success
  end
end

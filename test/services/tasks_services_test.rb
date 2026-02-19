require "test_helper"

class TasksServicesTest < ActiveSupport::TestCase
  test "create service persists task and logs activity" do
    result = nil

    assert_enqueued_emails 1 do
      assert_difference [ "Task.count", "ActivityEvent.count" ], 1 do
        result = Tasks::Create.call(
          project: projects(:core),
          creator: users(:alice),
          params: {
            title: "Service task",
            description: "Created via service",
            assignee_id: users(:bob).id,
            status: :todo,
            priority: :medium
          }
        )
      end
    end

    assert result.success?
    assert_equal users(:alice), result.record.creator
  end

  test "update service rejects stale object" do
    task = tasks(:auth_review)
    stale_version = task.lock_version
    task.update!(description: "Concurrent change")
    task.lock_version = stale_version

    result = Tasks::Update.call(
      task:,
      actor: users(:alice),
      params: { description: "Stale attempt", lock_version: stale_version }
    )

    assert_not result.success?
    assert_includes result.record.errors[:base], "Task was changed by another user. Reload and try again."
  end

  test "create service skips assignment email when recipient opted out" do
    notification_preferences(:bob).update!(assignment_enabled: false)

    assert_enqueued_emails 0 do
      Tasks::Create.call(
        project: projects(:core),
        creator: users(:alice),
        params: {
          title: "No email task",
          description: "Opted-out assignee",
          assignee_id: users(:bob).id,
          status: :todo,
          priority: :medium
        }
      )
    end
  end

  test "update service sends assignment email on assignee change" do
    assert_enqueued_emails 1 do
      Tasks::Update.call(
        task: tasks(:auth_review),
        actor: users(:alice),
        params: { assignee_id: users(:bob).id, lock_version: tasks(:auth_review).lock_version }
      )
    end
  end

  test "update service emits structured log with task context" do
    logged_payloads = []
    original = Observability::StructuredLogger.method(:log)

    Observability::StructuredLogger.define_singleton_method(:log) do |**payload|
      logged_payloads << payload
    end

    Tasks::Update.call(
      task: tasks(:auth_review),
      actor: users(:alice),
      params: { description: "Log me", lock_version: tasks(:auth_review).lock_version }
    )

    payload = logged_payloads.find { |entry| entry[:event] == "task.updated" }
    assert payload
    assert_equal users(:alice), payload[:actor]
    assert_equal tasks(:auth_review), payload[:task]
    assert_equal projects(:core), payload[:project]
  ensure
    Observability::StructuredLogger.define_singleton_method(:log, original)
  end
end

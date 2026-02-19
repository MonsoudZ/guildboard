require "test_helper"
require "stringio"
require "json"

class Observability::StructuredLoggerTest < ActiveSupport::TestCase
  test "emits structured payload with context ids and filtered metadata" do
    io = StringIO.new
    logger = ActiveSupport::Logger.new(io)
    original_logger = Rails.logger
    Rails.logger = logger

    Observability::StructuredLogger.log(
      event: "task.updated",
      request_id: "req-123",
      actor: users(:alice),
      organization: organizations(:acme),
      project: projects(:core),
      task: tasks(:backlog),
      metadata: {
        safe_key: "safe",
        email: "alice@example.test",
        nested: { token: "sensitive" }
      }
    )

    logger.flush if logger.respond_to?(:flush)
    raw_line = io.string.lines.last
    payload = JSON.parse(raw_line)

    assert_equal "task.updated", payload["event"]
    assert_equal "req-123", payload["request_id"]
    assert_equal users(:alice).id, payload["actor_id"]
    assert_equal organizations(:acme).id, payload["organization_id"]
    assert_equal projects(:core).id, payload["project_id"]
    assert_equal tasks(:backlog).id, payload["task_id"]
    assert_equal "safe", payload.fetch("metadata").fetch("safe_key")
    assert_equal "[FILTERED]", payload.fetch("metadata").fetch("email")
    assert_equal "[FILTERED]", payload.fetch("metadata").fetch("nested").fetch("token")
  ensure
    Rails.logger = original_logger
  end
end

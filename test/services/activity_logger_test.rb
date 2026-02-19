require "test_helper"

class ActivityLoggerTest < ActiveSupport::TestCase
  test "creates activity event with metadata" do
    assert_difference "ActivityEvent.count", 1 do
      ActivityLogger.log!(
        organization: organizations(:acme),
        actor: users(:alice),
        event_type: "task.updated",
        subject: tasks(:backlog),
        metadata: { changed_fields: [ "status" ] }
      )
    end

    event = ActivityEvent.order(:id).last
    assert_equal "task.updated", event.event_type
    assert_equal "status", event.metadata["changed_fields"].first
  end
end

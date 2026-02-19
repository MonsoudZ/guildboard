require "test_helper"

class ActivityEventTest < ActiveSupport::TestCase
  test "is immutable after creation" do
    event = activity_events(:core_project_created)

    assert_not event.update(event_type: "project.updated")
    assert_includes event.errors[:base], "Activity events are immutable"
    assert_not event.destroy
  end
end

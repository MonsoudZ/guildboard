require "test_helper"

class NotificationPreferenceTest < ActiveSupport::TestCase
  test "enforces one preference record per user" do
    duplicate = NotificationPreference.new(user: users(:alice), digest_enabled: false, assignment_enabled: false)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end

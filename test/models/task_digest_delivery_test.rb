require "test_helper"

class TaskDigestDeliveryTest < ActiveSupport::TestCase
  test "enforces one digest delivery per user per day" do
    duplicate = TaskDigestDelivery.new(user: users(:alice), delivered_on: Date.new(2026, 2, 18))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:delivered_on], "has already been taken"
  end
end

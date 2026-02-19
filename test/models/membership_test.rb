require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "prevents duplicate user membership in same organization" do
    duplicate = Membership.new(user: users(:alice), organization: organizations(:acme), role: :member)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end

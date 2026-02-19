require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  test "view requires membership" do
    assert OrganizationPolicy.new(users(:alice), organizations(:acme)).view?
    assert_not OrganizationPolicy.new(users(:charlie), organizations(:acme)).view?
  end

  test "invite requires manager or owner" do
    assert OrganizationPolicy.new(users(:alice), organizations(:acme)).invite_members?
    assert_not OrganizationPolicy.new(users(:bob), organizations(:acme)).invite_members?
  end

  test "manage tasks allows regular members" do
    assert OrganizationPolicy.new(users(:bob), organizations(:acme)).manage_tasks?
  end
end

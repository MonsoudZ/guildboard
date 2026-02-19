require "test_helper"

class ProjectPolicyTest < ActiveSupport::TestCase
  test "project access follows organization membership policy" do
    assert ProjectPolicy.new(users(:alice), projects(:core)).view?
    assert ProjectPolicy.new(users(:bob), projects(:core)).create?
    assert_not ProjectPolicy.new(users(:charlie), projects(:core)).update?
  end
end

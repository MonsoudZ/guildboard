require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "issue_for generates retrievable raw token" do
    token = ApiToken.issue_for(users(:alice), name: "cli")

    assert token.raw_token.present?
    found = ApiToken.find_active_by_raw_token(token.raw_token)
    assert_equal token, found
  end

  test "find_active_by_raw_token ignores revoked token" do
    assert_nil ApiToken.find_active_by_raw_token("bob-token")
  end
end

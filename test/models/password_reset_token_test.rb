require "test_helper"

class PasswordResetTokenTest < ActiveSupport::TestCase
  test "issue_for invalidates existing active tokens for user" do
    existing = password_reset_tokens(:active_alice)

    issued = PasswordResetToken.issue_for(users(:alice))

    assert existing.reload.used_at.present?
    assert issued.raw_token.present?
    assert issued.active?
  end

  test "find_active_by_raw_token returns nil for used or expired tokens" do
    assert_nil PasswordResetToken.find_active_by_raw_token("used-token")
    assert_nil PasswordResetToken.find_active_by_raw_token("expired-token")
    assert_nil PasswordResetToken.find_active_by_raw_token("missing-token")
  end

  test "find_active_by_raw_token returns active token" do
    token = PasswordResetToken.find_active_by_raw_token("active-token")

    assert_equal password_reset_tokens(:active_alice), token
  end
end

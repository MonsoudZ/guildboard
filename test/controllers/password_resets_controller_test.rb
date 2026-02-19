require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "renders request form" do
    get new_password_reset_url
    assert_response :success
  end

  test "create does not reveal whether email exists" do
    assert_enqueued_emails 0 do
      post password_resets_url, params: { email: "missing@example.test" }
    end

    assert_redirected_to new_session_url
    assert_equal "If that email exists, we have sent password reset instructions.", flash[:notice]
  end

  test "create enqueues reset email for existing user" do
    assert_difference "AuditLog.count", 1 do
      assert_enqueued_emails 1 do
        post password_resets_url, params: { email: users(:alice).email }
      end
    end

    assert_redirected_to new_session_url
    assert_equal "auth.password_reset_requested", AuditLog.order(:id).last.action
  end

  test "rejects expired or invalid token on edit" do
    get edit_password_reset_url("expired-token")
    assert_redirected_to new_password_reset_url
  end

  test "updates password, consumes token, and invalidates old session" do
    old_client = open_session
    old_client.post session_path, params: { email: users(:alice).email, password: "password123456" }
    old_client.get root_path
    assert_equal 200, old_client.response.status

    token = PasswordResetToken.issue_for(users(:alice))

    assert_difference "AuditLog.count", 1 do
      patch password_reset_url(token.raw_token), params: {
        user: {
          password: "newpassword123456",
          password_confirmation: "newpassword123456"
        }
      }
    end

    assert_redirected_to root_url
    assert token.reload.used_at.present?
    assert_equal 1, users(:alice).reload.session_version
    assert_equal "auth.password_reset_completed", AuditLog.order(:id).last.action

    old_client.get root_path
    assert_equal 302, old_client.response.status
    assert_equal new_session_url, old_client.response.redirect_url
  end

  test "update with invalid password rerenders form" do
    token = PasswordResetToken.issue_for(users(:alice))

    patch password_reset_url(token.raw_token), params: {
      user: {
        password: "short",
        password_confirmation: "short"
      }
    }

    assert_response :unprocessable_entity
    assert token.reload.used_at.nil?
  end
end

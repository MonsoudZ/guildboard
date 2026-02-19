require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "shows sign in form" do
    get new_session_url
    assert_response :success
  end

  test "creates session with valid credentials" do
    assert_difference "AuditLog.count", 1 do
      post session_url, params: { email: users(:alice).email, password: "password123456" }
    end

    assert_redirected_to root_url
    assert_equal "auth.sign_in", AuditLog.order(:id).last.action
  end

  test "rejects invalid credentials" do
    assert_difference "AuditLog.count", 1 do
      post session_url, params: { email: users(:alice).email, password: "wrong-password" }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Invalid email or password"
    assert_equal "auth.sign_in_failed", AuditLog.order(:id).last.action
  end

  test "destroys session" do
    sign_in_as(users(:alice))

    assert_difference "AuditLog.count", 1 do
      delete session_url
    end

    assert_redirected_to new_session_url
    assert_equal "auth.sign_out", AuditLog.order(:id).last.action
  end

  test "stale session version is rejected" do
    sign_in_as(users(:alice))
    users(:alice).invalidate_all_sessions!

    get root_url
    assert_redirected_to new_session_url
  end
end

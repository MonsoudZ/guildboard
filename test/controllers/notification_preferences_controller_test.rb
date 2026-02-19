require "test_helper"

class NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get edit_notification_preference_url
    assert_redirected_to new_session_url
  end

  test "shows preferences for signed in user" do
    sign_in_as(users(:alice))
    get edit_notification_preference_url
    assert_response :success
  end

  test "updates preferences" do
    sign_in_as(users(:alice))

    patch notification_preference_url, params: {
      notification_preference: {
        digest_enabled: false,
        assignment_enabled: false
      }
    }

    assert_redirected_to edit_notification_preference_url
    assert_equal false, users(:alice).notification_preference.reload.digest_enabled
    assert_equal false, users(:alice).notification_preference.reload.assignment_enabled
  end
end

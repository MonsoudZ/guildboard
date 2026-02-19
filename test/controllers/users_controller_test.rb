require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "renders sign up page" do
    get new_user_url
    assert_response :success
  end

  test "creates user account" do
    assert_difference "User.count" do
      post users_url, params: {
        user: {
          name: "New User",
          email: "new-user@example.test",
          password: "password123456",
          password_confirmation: "password123456"
        }
      }
    end

    assert_redirected_to root_url
  end
end

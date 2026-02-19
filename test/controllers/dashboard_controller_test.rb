require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get root_url
    assert_redirected_to new_session_url
  end

  test "renders for signed in users" do
    sign_in_as(users(:alice))
    get root_url
    assert_response :success
    assert_includes response.body, "Dashboard"
  end
end

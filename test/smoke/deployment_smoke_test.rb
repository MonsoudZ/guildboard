require "test_helper"

class DeploymentSmokeTest < ActionDispatch::IntegrationTest
  test "health check endpoint is up" do
    get "/up"
    assert_response :success
  end

  test "session sign in and dashboard render" do
    post session_url, params: { email: users(:alice).email, password: "password123456" }
    assert_redirected_to root_url

    follow_redirect!
    assert_response :success
    assert_includes response.body, "Dashboard"
  end

  test "api rejects missing bearer token" do
    get api_v1_organization_projects_url(organizations(:acme))
    assert_response :unauthorized
  end
end

require "test_helper"

class Observability::ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get observability_errors_url
    assert_redirected_to new_session_url
  end

  test "renders error dashboard for signed in user" do
    sign_in_as(users(:alice))

    get observability_errors_url

    assert_response :success
    assert_includes response.body, "Error Dashboard"
    assert_includes response.body, "record_not_found"
  end
end

require "test_helper"

class Api::V1::ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "requires bearer token" do
    get api_v1_organization_projects_url(organizations(:acme))
    assert_response :unauthorized
  end

  test "member can list projects" do
    token = ApiToken.issue_for(users(:alice), name: "test").raw_token

    get api_v1_organization_projects_url(organizations(:acme)), headers: auth_headers(token)

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "CORE", json.fetch("projects").first.fetch("key")
  end

  test "non member is forbidden" do
    token = ApiToken.issue_for(users(:charlie), name: "test").raw_token

    get api_v1_organization_projects_url(organizations(:acme)), headers: auth_headers(token)

    assert_response :forbidden
  end

  test "member can create project with json response" do
    token = ApiToken.issue_for(users(:alice), name: "test").raw_token

    assert_difference "Project.count", 1 do
      post api_v1_organization_projects_url(organizations(:acme)),
           headers: auth_headers(token),
           params: { project: { name: "API Project", key: "API", description: "json", status: :active } }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "API", json.fetch("project").fetch("key")
  end

  test "returns validation errors for invalid payload" do
    token = ApiToken.issue_for(users(:alice), name: "test").raw_token

    post api_v1_organization_projects_url(organizations(:acme)),
         headers: auth_headers(token),
         params: { project: { name: "", key: "", status: :active } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].is_a?(Array)
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end

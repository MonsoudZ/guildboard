require "test_helper"

class Api::V1::TasksControllerTest < ActionDispatch::IntegrationTest
  test "requires bearer token" do
    get api_v1_organization_project_tasks_url(organizations(:acme), projects(:core))
    assert_response :unauthorized
  end

  test "member can list tasks" do
    token = ApiToken.issue_for(users(:alice), name: "test").raw_token

    get api_v1_organization_project_tasks_url(organizations(:acme), projects(:core)), headers: auth_headers(token)

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Build initial backlog", json.fetch("tasks").first.fetch("title")
  end

  test "member can create task" do
    token = ApiToken.issue_for(users(:alice), name: "test").raw_token

    assert_difference "Task.count", 1 do
      post api_v1_organization_project_tasks_url(organizations(:acme), projects(:core)),
           headers: auth_headers(token),
           params: {
             task: {
               title: "API task",
               description: "from api",
               assignee_id: users(:bob).id,
               status: :todo,
               priority: :high
             }
           }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "API task", json.fetch("task").fetch("title")
  end

  test "non member is forbidden" do
    token = ApiToken.issue_for(users(:charlie), name: "test").raw_token

    get api_v1_organization_project_tasks_url(organizations(:acme), projects(:core)), headers: auth_headers(token)

    assert_response :forbidden
  end

  test "returns validation errors for invalid payload" do
    token = ApiToken.issue_for(users(:alice), name: "test").raw_token

    post api_v1_organization_project_tasks_url(organizations(:acme), projects(:core)),
         headers: auth_headers(token),
         params: { task: { title: "", assignee_id: users(:bob).id, status: :todo, priority: :medium } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].is_a?(Array)
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end

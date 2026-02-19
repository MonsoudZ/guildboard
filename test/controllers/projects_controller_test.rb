require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "member can create project" do
    sign_in_as(users(:alice))

    assert_difference [ "Project.count", "ActivityEvent.count" ] do
      post organization_projects_url(organizations(:acme)), params: {
        project: { name: "Mobile API", key: "MOBILE", description: "App backend", status: :active }
      }
    end

    created = Project.find_by!(key: "MOBILE")
    assert_redirected_to organization_project_url(organizations(:acme), created)
  end

  test "non member cannot create project" do
    sign_in_as(users(:charlie))

    assert_no_difference "Project.count" do
      post organization_projects_url(organizations(:acme)), params: {
        project: { name: "Hidden", key: "HIDDEN", description: "", status: :active }
      }
    end

    assert_redirected_to organizations_url
  end

  test "cannot update archived project" do
    sign_in_as(users(:alice))

    patch organization_project_url(organizations(:acme), projects(:legacy)), params: {
      project: { name: "Renamed legacy", status: :archived }
    }

    assert_redirected_to organization_project_url(organizations(:acme), projects(:legacy))
    assert_equal "Legacy Migration", projects(:legacy).reload.name
  end

  test "updating project creates activity event" do
    sign_in_as(users(:alice))

    assert_difference "ActivityEvent.count", 1 do
      patch organization_project_url(organizations(:acme), projects(:core)), params: {
        project: { description: "Updated details", status: :active }
      }
    end

    assert_redirected_to organization_project_url(organizations(:acme), projects(:core))
  end

  test "stale project update is rejected" do
    sign_in_as(users(:alice))
    stale_lock_version = projects(:core).lock_version
    projects(:core).update!(description: "Competing update")

    patch organization_project_url(organizations(:acme), projects(:core)), params: {
      project: { description: "My stale update", lock_version: stale_lock_version }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "Project was changed by another user. Reload and try again."
  end

  test "soft deleted project is hidden until restored" do
    sign_in_as(users(:alice))
    project = projects(:core)
    project.soft_delete!

    get organization_project_url(organizations(:acme), project)
    assert_response :not_found

    Project.with_deleted.find(project.id).restore!
    get organization_project_url(organizations(:acme), project)
    assert_response :success
  end

  test "record not found is captured as classified error event" do
    sign_in_as(users(:alice))

    assert_difference "ErrorEvent.count", 1 do
      get organization_project_url(organizations(:acme), 999_999)
      assert_response :not_found
    end

    error_event = ErrorEvent.recent.first
    assert_equal "record_not_found", error_event.classification
    assert_equal users(:alice), error_event.user
    assert_equal organizations(:acme), error_event.organization
    assert_equal "GET", error_event.http_method
  end
end

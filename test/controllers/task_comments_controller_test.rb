require "test_helper"

class TaskCommentsControllerTest < ActionDispatch::IntegrationTest
  test "member can add comment" do
    sign_in_as(users(:bob))

    assert_difference [ "TaskComment.count", "ActivityEvent.count" ] do
      post organization_project_task_task_comments_url(organizations(:acme), projects(:core), tasks(:backlog)), params: {
        task_comment: { body: "Comment from controller test." }
      }
    end

    assert_redirected_to organization_project_task_url(organizations(:acme), projects(:core), tasks(:backlog))
  end

  test "non member cannot add comment" do
    sign_in_as(users(:charlie))

    assert_no_difference "TaskComment.count" do
      post organization_project_task_task_comments_url(organizations(:acme), projects(:core), tasks(:backlog)), params: {
        task_comment: { body: "Should be blocked." }
      }
    end

    assert_redirected_to organizations_url
  end

  test "cannot add comment on archived project task" do
    sign_in_as(users(:alice))

    assert_no_difference "TaskComment.count" do
      post organization_project_task_task_comments_url(organizations(:acme), projects(:legacy), tasks(:legacy_task)), params: {
        task_comment: { body: "Should not be added." }
      }
    end

    assert_redirected_to organization_project_url(organizations(:acme), projects(:legacy))
  end
end

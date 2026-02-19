require "test_helper"

class QueryBudgetTest < ActionDispatch::IntegrationTest
  test "dashboard query budget" do
    sign_in_as(users(:alice))

    queries = count_queries { get root_url }

    assert_response :success
    assert_operator queries, :<=, 20
  end

  test "project show query budget" do
    sign_in_as(users(:alice))

    queries = count_queries { get organization_project_url(organizations(:acme), projects(:core)) }

    assert_response :success
    assert_operator queries, :<=, 20
  end
end

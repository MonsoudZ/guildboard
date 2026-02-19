require "test_helper"

class OrganizationSearchesControllerTest < ActionDispatch::IntegrationTest
  test "member can search within organization" do
    sign_in_as(users(:alice))

    get organization_search_url(organizations(:acme), q: "backlog")

    assert_response :success
    assert_includes response.body, "Build initial backlog"
  end

  test "search is scoped to organization" do
    sign_in_as(users(:alice))

    get organization_search_url(organizations(:acme), q: "site")

    assert_response :success
    assert_not_includes response.body, "SITE - Marketing Site"
  end

  test "ranks exact project key match above partial match" do
    sign_in_as(users(:alice))
    Project.create!(organization: organizations(:acme), name: "Core Docs", key: "XCORE", description: "docs", status: :active)

    get organization_search_url(organizations(:acme), q: "core")

    exact_index = response.body.index("CORE - Core Platform")
    partial_index = response.body.index("XCORE - Core Docs")
    assert exact_index
    assert partial_index
    assert_operator exact_index, :<, partial_index
  end

  test "non member cannot search organization" do
    sign_in_as(users(:charlie))
    get organization_search_url(organizations(:zen), q: "site")

    assert_redirected_to organizations_url
  end
end

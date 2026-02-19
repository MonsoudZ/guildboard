require "test_helper"

class OrganizationSearchQueryTest < ActiveSupport::TestCase
  test "search scopes results to organization" do
    result = OrganizationSearchQuery.call(organization: organizations(:acme), query: "site", page: 1)

    assert_empty result.projects
  end

  test "exact key match is ranked first" do
    Project.create!(organization: organizations(:acme), name: "Core Docs", key: "XCORE", description: "docs", status: :active)

    result = OrganizationSearchQuery.call(organization: organizations(:acme), query: "core", page: 1)

    assert_equal "CORE", result.projects.first.key
  end

  test "supports pagination flags" do
    21.times do |i|
      Project.create!(
        organization: organizations(:acme),
        name: "Search #{i}",
        key: "S#{i}",
        description: "search content",
        status: :active
      )
    end

    page_one = OrganizationSearchQuery.call(organization: organizations(:acme), query: "search", page: 1)
    page_two = OrganizationSearchQuery.call(organization: organizations(:acme), query: "search", page: 2)

    assert_equal 20, page_one.projects.size
    assert page_one.more_projects
    assert_equal 1, page_two.projects.size
    assert_not page_two.more_projects
  end
end

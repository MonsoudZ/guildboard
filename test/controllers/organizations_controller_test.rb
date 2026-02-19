require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "creates organization and owner membership" do
    sign_in_as(users(:alice))

    assert_difference [ "Organization.count", "Membership.count" ] do
      post organizations_url, params: { organization: { name: "Nova Works", slug: "nova-works" } }
    end

    created = Organization.find_by!(slug: "nova-works")
    assert Membership.exists?(user: users(:alice), organization: created, role: :owner)
    assert_redirected_to organization_url(created)
  end

  test "blocks non members from viewing organization" do
    sign_in_as(users(:charlie))
    get organization_url(organizations(:acme))

    assert_redirected_to organizations_url
  end
end

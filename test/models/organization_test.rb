require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "normalizes slug from name-like input" do
    organization = Organization.new(name: "Acme Two", slug: "Acme Two Inc")

    assert organization.valid?
    assert_equal "acme-two-inc", organization.slug
  end
end

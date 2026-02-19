require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "normalizes key to uppercase" do
    project = Project.new(
      organization: organizations(:acme),
      name: "Docs",
      key: "docs",
      status: :active
    )

    assert project.valid?
    assert_equal "DOCS", project.key
  end
end

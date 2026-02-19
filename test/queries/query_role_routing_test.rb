require "test_helper"

class QueryRoleRoutingTest < ActiveSupport::TestCase
  test "dashboard snapshot query routes through read role" do
    called = false
    original = DatabaseRole.method(:read)

    DatabaseRole.define_singleton_method(:read) do |&block|
      called = true
      block.call
    end

    begin
      DashboardSnapshotQuery.call(user: users(:alice))
    ensure
      DatabaseRole.define_singleton_method(:read, original)
    end

    assert called
  end

  test "organization search query routes through read role" do
    read_calls = 0
    original = DatabaseRole.method(:read)

    DatabaseRole.define_singleton_method(:read) do |&block|
      read_calls += 1
      block.call
    end

    begin
      OrganizationSearchQuery.call(organization: organizations(:acme), query: "core", page: 1)
    ensure
      DatabaseRole.define_singleton_method(:read, original)
    end

    assert_operator read_calls, :>=, 2
  end
end

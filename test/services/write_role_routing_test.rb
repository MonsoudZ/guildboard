require "test_helper"

class WriteRoleRoutingTest < ActiveSupport::TestCase
  test "project create service routes through write role" do
    called = false
    original = DatabaseRole.method(:write)

    DatabaseRole.define_singleton_method(:write) do |&block|
      called = true
      block.call
    end

    begin
      Projects::Create.call(
        organization: organizations(:acme),
        actor: users(:alice),
        params: { name: "Role Routed", key: "ROLE_ROUTED", description: "routing", status: :active }
      )
    ensure
      DatabaseRole.define_singleton_method(:write, original)
    end

    assert called
  end

  test "task update service routes through write role" do
    called = false
    original = DatabaseRole.method(:write)

    DatabaseRole.define_singleton_method(:write) do |&block|
      called = true
      block.call
    end

    begin
      Tasks::Update.call(
        task: tasks(:auth_review),
        actor: users(:alice),
        params: { description: "Role routing update", lock_version: tasks(:auth_review).lock_version }
      )
    ensure
      DatabaseRole.define_singleton_method(:write, original)
    end

    assert called
  end
end

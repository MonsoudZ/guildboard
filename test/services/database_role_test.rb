require "test_helper"

class DatabaseRoleTest < ActiveSupport::TestCase
  test "read role switches to replica connection role" do
    observed_role = nil

    DatabaseRole.read do
      observed_role = ApplicationRecord.current_role
      Project.count
    end

    assert_equal :reading, observed_role
  end

  test "write role uses primary connection role" do
    observed_role = nil

    DatabaseRole.write do
      observed_role = ApplicationRecord.current_role
      Project.count
    end

    assert_equal :writing, observed_role
  end

  test "read role prevents writes" do
    assert_raises ActiveRecord::ReadOnlyError do
      DatabaseRole.read do
        Organization.create!(name: "Replica Write", slug: "replica-write")
      end
    end
  end
end

require "test_helper"

class DashboardSnapshotQueryTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test "caches dashboard snapshot" do
    key = DashboardSnapshotQuery.cache_key_for(user: users(:alice))
    assert_nil Rails.cache.read(key)

    snapshot = DashboardSnapshotQuery.call(user: users(:alice))

    assert_equal snapshot, Rails.cache.read(key)
    assert_equal snapshot, DashboardSnapshotQuery.call(user: users(:alice))
  end

  test "cache key changes when assigned task updates" do
    old_key = DashboardSnapshotQuery.cache_key_for(user: users(:alice))

    tasks(:auth_review).update!(description: "Cache invalidation update")

    new_key = DashboardSnapshotQuery.cache_key_for(user: users(:alice))
    assert_not_equal old_key, new_key
  end
end

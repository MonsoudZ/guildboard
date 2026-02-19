class DashboardSnapshotQuery
  EXPIRY = 15.minutes

  def self.call(user:)
    DatabaseRole.read do
      key = cache_key_for(user:)

      Rails.cache.fetch(key, expires_in: EXPIRY) do
        {
          organization_ids: user.organizations.order(:name).pluck(:id),
          assigned_task_ids: DashboardAssignedTasksQuery.call(user:, limit: 10).pluck(:id)
        }
      end
    end
  end

  def self.cache_key_for(user:)
    membership_version = DatabaseRole.read { Membership.where(user:).maximum(:updated_at)&.utc&.iso8601(6) } || "0"
    task_version = DatabaseRole.read { Task.where(assignee: user).maximum(:updated_at)&.utc&.iso8601(6) } || "0"

    "dashboard/#{user.id}/v1-#{membership_version}-#{task_version}"
  end
end

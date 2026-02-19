class DashboardAssignedTasksQuery
  def self.call(user:, limit: 10)
    DatabaseRole.read do
      Task.includes(:project, :creator)
          .where(assignee: user)
          .open_statuses
          .recent
          .limit(limit)
    end
  end
end

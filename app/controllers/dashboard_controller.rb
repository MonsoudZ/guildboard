class DashboardController < ApplicationController
  def index
    snapshot = DashboardSnapshotQuery.call(user: current_user)
    @organizations = ordered_records(Organization.where(id: snapshot[:organization_ids]), snapshot[:organization_ids])
    @assigned_tasks = ordered_records(
      Task.includes(:project, :creator).where(id: snapshot[:assigned_task_ids]),
      snapshot[:assigned_task_ids]
    )
  end

  private

  def ordered_records(scope, ids)
    records_by_id = scope.index_by(&:id)
    ids.filter_map { |id| records_by_id[id] }
  end
end

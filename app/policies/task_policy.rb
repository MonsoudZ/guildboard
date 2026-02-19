class TaskPolicy < ApplicationPolicy
  def view?
    organization_policy.manage_tasks?
  end

  def create?
    organization_policy.manage_tasks?
  end

  def update?
    organization_policy.manage_tasks?
  end

  def comment?
    organization_policy.manage_tasks?
  end

  private

  def organization_policy
    @organization_policy ||= OrganizationPolicy.new(user, record.project.organization)
  end
end

class ProjectPolicy < ApplicationPolicy
  def view?
    organization_policy.view?
  end

  def create?
    organization_policy.manage_projects?
  end

  def update?
    organization_policy.manage_projects?
  end

  private

  def organization_policy
    @organization_policy ||= OrganizationPolicy.new(user, record.organization)
  end
end

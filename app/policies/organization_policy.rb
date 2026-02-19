class OrganizationPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def view?
    membership.present?
  end

  def search?
    view?
  end

  def manage_projects?
    view?
  end

  def manage_tasks?
    view?
  end

  def invite_members?
    membership&.manager? || membership&.owner?
  end

  private

  def membership
    @membership ||= membership_for(record)
  end
end

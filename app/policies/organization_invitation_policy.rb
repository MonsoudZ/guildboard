class OrganizationInvitationPolicy < ApplicationPolicy
  def create?
    OrganizationPolicy.new(user, record.organization).invite_members?
  end

  def view?
    create?
  end
end

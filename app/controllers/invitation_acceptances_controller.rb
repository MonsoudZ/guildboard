class InvitationAcceptancesController < ApplicationController
  skip_before_action :require_authentication, only: :edit
  before_action :set_invitation

  def edit
  end

  def update
    unless signed_in?
      redirect_to new_session_path, alert: "Sign in to accept this invitation."
      return
    end

    unless invited_user?
      redirect_to edit_invitation_acceptance_path(params[:token]), alert: "Sign in with #{invitation.email} to accept this invitation."
      return
    end

    OrganizationInvitation.transaction do
      Membership.find_or_create_by!(organization: invitation.organization, user: current_user) do |membership|
        membership.role = invitation.role
      end
      invitation.accept!(user: current_user)
      ActivityLogger.log!(
        organization: invitation.organization,
        actor: current_user,
        event_type: "organization.invitation_accepted",
        subject: invitation,
        metadata: { email: invitation.email, role: invitation.role }
      )
      AuditLogger.log!(
        action: "membership.invitation_accepted",
        actor: current_user,
        organization: invitation.organization,
        auditable: invitation,
        metadata: { email: invitation.email, role: invitation.role },
        request:
      )
    end

    redirect_to organization_path(invitation.organization), notice: "You have joined #{invitation.organization.name}."
  end

  private

  attr_reader :invitation

  def set_invitation
    @invitation = OrganizationInvitation.find_pending_by_raw_token(params[:token])
    return if @invitation.present?

    redirect_to root_path, alert: "That invitation link is invalid or expired."
  end

  def invited_user?
    current_user.email.downcase == invitation.email
  end
end

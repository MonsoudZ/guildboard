class OrganizationInvitationsController < ApplicationController
  before_action :set_organization
  before_action :authorize_membership!
  before_action :require_inviter_role!

  def new
    @invitation = @organization.organization_invitations.new(role: :member)
  end

  def create
    invitation_params = params.expect(organization_invitation: [ :email, :role ])
    @invitation = @organization.organization_invitations.new(invitation_params)

    invitation = OrganizationInvitation.issue!(
      organization: @organization,
      invited_by: current_user,
      email: invitation_params[:email],
      role: invitation_params[:role]
    )
    OrganizationInvitationMailer.with(invitation:, token: invitation.raw_token).invite.deliver_later
    ActivityLogger.log!(
      organization: @organization,
      actor: current_user,
      event_type: "organization.invitation_sent",
      subject: invitation,
      metadata: { email: invitation.email, role: invitation.role }
    )
    AuditLogger.log!(
      action: "membership.invitation_sent",
      actor: current_user,
      organization: @organization,
      auditable: invitation,
      metadata: { email: invitation.email, role: invitation.role },
      request:
    )

    redirect_to organization_path(@organization), notice: "Invitation sent to #{invitation.email}."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def authorize_membership!
    authorize_policy!(@organization, :view, fallback: organizations_path)
  end

  def require_inviter_role!
    return if OrganizationPolicy.new(current_user, @organization).invite_members?

    redirect_to organization_path(@organization), alert: "Only managers or owners can invite members."
  end
end

class OrganizationInvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @organization = @invitation.organization
    @accept_url = edit_invitation_acceptance_url(params[:token])

    mail to: @invitation.email, subject: "Invitation to join #{@organization.name} on GuildBoard"
  end
end

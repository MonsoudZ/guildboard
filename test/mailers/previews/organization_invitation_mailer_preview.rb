# Preview all emails at http://localhost:3000/rails/mailers/organization_invitation_mailer
class OrganizationInvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/organization_invitation_mailer/invite
  def invite
    invitation = OrganizationInvitation.first || OrganizationInvitation.new(
      organization: Organization.first || Organization.new(name: "Preview Org", slug: "preview-org"),
      invited_by: User.first || User.new(name: "Preview Inviter", email: "inviter@example.test"),
      email: "invitee@example.test",
      role: :member,
      token_digest: OrganizationInvitation.digest("preview-token"),
      expires_at: 7.days.from_now
    )
    OrganizationInvitationMailer.with(invitation:, token: "preview-token").invite
  end
end

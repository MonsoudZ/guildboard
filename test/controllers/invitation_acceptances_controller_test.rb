require "test_helper"

class InvitationAcceptancesControllerTest < ActionDispatch::IntegrationTest
  test "renders edit page for valid invitation token" do
    get edit_invitation_acceptance_url("invite-token-bob")
    assert_response :success
  end

  test "update requires sign in" do
    patch invitation_acceptance_url("invite-token-bob")
    assert_redirected_to new_session_url
  end

  test "signed in user must match invited email" do
    sign_in_as(users(:alice))

    patch invitation_acceptance_url("invite-token-bob")
    assert_redirected_to edit_invitation_acceptance_url("invite-token-bob")
  end

  test "accepts invitation and creates membership for invited user" do
    invitation = OrganizationInvitation.issue!(
      organization: organizations(:acme),
      invited_by: users(:alice),
      email: users(:charlie).email,
      role: :member
    )

    sign_in_as(users(:charlie))

    assert_difference [ "Membership.count", "ActivityEvent.count", "AuditLog.count" ], 1 do
      patch invitation_acceptance_url(invitation.raw_token)
    end

    assert invitation.reload.accepted_at.present?
    assert_equal users(:charlie), invitation.accepted_by
    assert Membership.exists?(organization: organizations(:acme), user: users(:charlie))
    assert_redirected_to organization_url(organizations(:acme))
  end

  test "expired invitation token is rejected" do
    get edit_invitation_acceptance_url("invite-token-expired")
    assert_redirected_to root_url
  end
end

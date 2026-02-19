require "test_helper"

class OrganizationInvitationTest < ActiveSupport::TestCase
  test "issue invalidates previous pending invitation for same email and org" do
    existing = organization_invitations(:pending_bob)

    invitation = OrganizationInvitation.issue!(
      organization: organizations(:acme),
      invited_by: users(:alice),
      email: "bob@example.test",
      role: :member
    )

    assert existing.reload.expires_at <= Time.current
    assert invitation.pending?
    assert invitation.raw_token.present?
  end

  test "find_pending_by_raw_token rejects expired token" do
    assert_nil OrganizationInvitation.find_pending_by_raw_token("invite-token-expired")
  end

  test "find_pending_by_raw_token returns pending invitation" do
    invitation = OrganizationInvitation.find_pending_by_raw_token("invite-token-bob")

    assert_equal organization_invitations(:pending_bob), invitation
  end
end

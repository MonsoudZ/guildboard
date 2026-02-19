require "test_helper"

class OrganizationInvitationMailerTest < ActionMailer::TestCase
  test "invite" do
    mail = OrganizationInvitationMailer.with(
      invitation: organization_invitations(:pending_bob),
      token: "token123"
    ).invite

    assert_equal "Invitation to join Acme Labs on GuildBoard", mail.subject
    assert_equal [ "bob@example.test" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "token123", mail.body.encoded
  end
end

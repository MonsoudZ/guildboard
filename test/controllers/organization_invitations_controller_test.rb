require "test_helper"

class OrganizationInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "owner can invite member" do
    sign_in_as(users(:alice))

    assert_enqueued_emails 1 do
      assert_difference [ "OrganizationInvitation.count", "ActivityEvent.count", "AuditLog.count" ] do
        post organization_organization_invitations_url(organizations(:acme)), params: {
          organization_invitation: {
            email: "new-person@example.test",
            role: :member
          }
        }
      end
    end

    assert_redirected_to organization_url(organizations(:acme))
  end

  test "member cannot invite users" do
    sign_in_as(users(:bob))

    assert_no_difference "OrganizationInvitation.count" do
      post organization_organization_invitations_url(organizations(:acme)), params: {
        organization_invitation: {
          email: "blocked@example.test",
          role: :member
        }
      }
    end

    assert_redirected_to organization_url(organizations(:acme))
  end

  test "renders form for owners" do
    sign_in_as(users(:alice))
    get new_organization_organization_invitation_url(organizations(:acme))
    assert_response :success
  end
end

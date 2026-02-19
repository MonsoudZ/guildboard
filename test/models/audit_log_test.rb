require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "is immutable after insert" do
    log = audit_logs(:alice_sign_in)

    assert_not log.update(action: "auth.sign_out")
    assert_includes log.errors[:base], "Audit logs are immutable"
    assert_not log.destroy
  end
end

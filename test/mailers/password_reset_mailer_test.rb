require "test_helper"

class PasswordResetMailerTest < ActionMailer::TestCase
  test "reset" do
    mail = PasswordResetMailer.with(user: users(:alice), token: "abc123token").reset

    assert_equal "Reset your GuildBoard password", mail.subject
    assert_equal [ users(:alice).email ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "abc123token", mail.body.encoded
  end
end

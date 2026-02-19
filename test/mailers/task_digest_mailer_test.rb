require "test_helper"

class TaskDigestMailerTest < ActionMailer::TestCase
  test "due_digest" do
    mail = TaskDigestMailer.with(
      user: users(:bob),
      tasks: [ tasks(:backlog) ],
      for_date: Date.new(2026, 2, 27)
    ).due_digest

    assert_equal "Task digest for 2026-02-27", mail.subject
    assert_equal [ users(:bob).email ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Build initial backlog", mail.body.encoded
  end
end

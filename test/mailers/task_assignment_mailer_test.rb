require "test_helper"

class TaskAssignmentMailerTest < ActionMailer::TestCase
  test "assigned" do
    mail = TaskAssignmentMailer.with(task: tasks(:backlog), recipient: users(:bob)).assigned

    assert_equal "Assigned to task: Build initial backlog", mail.subject
    assert_equal [ users(:bob).email ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "CORE", mail.body.encoded
  end
end

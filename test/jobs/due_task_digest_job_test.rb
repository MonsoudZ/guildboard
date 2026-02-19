require "test_helper"

class DueTaskDigestJobTest < ActiveJob::TestCase
  test "sends one digest per user per day" do
    assert_difference "TaskDigestDelivery.count", 1 do
      assert_emails 1 do
        DueTaskDigestJob.perform_now(for_date: Date.new(2026, 2, 27))
      end
    end

    assert_no_difference "TaskDigestDelivery.count" do
      assert_emails 0 do
        DueTaskDigestJob.perform_now(for_date: Date.new(2026, 2, 27))
      end
    end
  end

  test "respects digest preference opt-out" do
    notification_preferences(:bob).update!(digest_enabled: false)

    assert_no_difference "TaskDigestDelivery.count" do
      assert_emails 0 do
        DueTaskDigestJob.perform_now(for_date: Date.new(2026, 2, 27))
      end
    end
  end
end

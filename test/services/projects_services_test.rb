require "test_helper"

class ProjectsServicesTest < ActiveSupport::TestCase
  test "create service persists project and logs activity" do
    result = nil

    assert_difference [ "Project.count", "ActivityEvent.count" ], 1 do
      result = Projects::Create.call(
        organization: organizations(:acme),
        actor: users(:alice),
        params: { name: "Payments", key: "PAY", description: "Billing", status: :active }
      )
    end

    assert result.success?
    assert_equal "PAY", result.record.key
  end

  test "update service rolls back event when record invalid" do
    result = nil

    assert_no_difference "ActivityEvent.count" do
      result = Projects::Update.call(
        project: projects(:core),
        actor: users(:alice),
        params: { key: "" }
      )
    end

    assert_not result.success?
    assert_includes result.record.errors[:key], "can't be blank"
  end

  test "create service emits structured log with project context" do
    logged_payloads = []
    original = Observability::StructuredLogger.method(:log)

    Observability::StructuredLogger.define_singleton_method(:log) do |**payload|
      logged_payloads << payload
    end

    Projects::Create.call(
      organization: organizations(:acme),
      actor: users(:alice),
      params: { name: "Logging", key: "LOGGING", description: "Observe me", status: :active }
    )

    payload = logged_payloads.find { |entry| entry[:event] == "project.created" }
    assert payload
    assert_equal users(:alice), payload[:actor]
    assert_equal organizations(:acme), payload[:organization]
  ensure
    Observability::StructuredLogger.define_singleton_method(:log, original)
  end
end

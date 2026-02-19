module Tasks
  class Update
    STALE_MESSAGE = "Task was changed by another user. Reload and try again."

    def self.call(task:, actor:, params:)
      new(task:, actor:, params:).call
    end

    def initialize(task:, actor:, params:)
      @task = task
      @actor = actor
      @params = params
    end

    def call
      notify_assignee = nil

      DatabaseRole.write do
        ActiveRecord::Base.transaction do
          task.update!(params)
          notify_assignee = task.assignee if task.saved_change_to_assignee_id? && should_send_assignment_email?(task.assignee)
          ActivityLogger.log!(
            organization: task.project.organization,
            actor:,
            event_type: "task.updated",
            subject: task,
            metadata: { changed_fields: task.saved_changes.except("updated_at").keys }
          )
          Observability::StructuredLogger.log(
            event: "task.updated",
            actor:,
            organization: task.project.organization,
            project: task.project,
            task:,
            metadata: { changed_fields: task.saved_changes.except("updated_at").keys }
          )
        end
      end

      TaskAssignmentMailer.with(task:, recipient: notify_assignee).assigned.deliver_later if notify_assignee

      ServiceResult.new(record: task)
    rescue ActiveRecord::StaleObjectError
      task.errors.add(:base, STALE_MESSAGE)
      ServiceResult.new(record: task, error: :stale)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.new(record: e.record, error: e)
    end

    private

    attr_reader :task, :actor, :params

    def should_send_assignment_email?(assignee)
      assignee.present? && assignee != actor && assignee.assignment_notifications_enabled?
    end
  end
end

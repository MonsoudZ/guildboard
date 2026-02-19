module Tasks
  class Create
    def self.call(project:, creator:, params:)
      new(project:, creator:, params:).call
    end

    def initialize(project:, creator:, params:)
      @project = project
      @creator = creator
      @params = params
    end

    def call
      @task = project.tasks.new(params)
      @task.creator = creator
      notify_assignee = nil

      DatabaseRole.write do
        ActiveRecord::Base.transaction do
          @task.save!
          notify_assignee = @task.assignee if should_send_assignment_email?(@task.assignee)
          ActivityLogger.log!(
            organization: project.organization,
            actor: creator,
            event_type: "task.created",
            subject: @task,
            metadata: { title: @task.title, project_key: project.key, assignee_id: @task.assignee_id }
          )
          Observability::StructuredLogger.log(
            event: "task.created",
            actor: creator,
            organization: project.organization,
            project:,
            task: @task,
            metadata: { status: @task.status, priority: @task.priority, assignee_id: @task.assignee_id }
          )
        end
      end

      TaskAssignmentMailer.with(task: @task, recipient: notify_assignee).assigned.deliver_later if notify_assignee

      ServiceResult.new(record: @task)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.new(record: @task || e.record, error: e)
    end

    private

    attr_reader :project, :creator, :params

    def should_send_assignment_email?(assignee)
      assignee.present? && assignee != creator && assignee.assignment_notifications_enabled?
    end
  end
end

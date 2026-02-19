module TaskComments
  class Create
    def self.call(task:, author:, params:)
      new(task:, author:, params:).call
    end

    def initialize(task:, author:, params:)
      @task = task
      @author = author
      @params = params
    end

    def call
      @task_comment = task.task_comments.new(params)
      @task_comment.author = author

      DatabaseRole.write do
        ActiveRecord::Base.transaction do
          @task_comment.save!
          ActivityLogger.log!(
            organization: task.project.organization,
            actor: author,
            event_type: "task.comment_added",
            subject: task,
            metadata: { task_comment_id: @task_comment.id }
          )
          Observability::StructuredLogger.log(
            event: "task.comment_added",
            actor: author,
            organization: task.project.organization,
            project: task.project,
            task:,
            metadata: { task_comment_id: @task_comment.id }
          )
        end
      end

      ServiceResult.new(record: @task_comment)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.new(record: @task_comment || e.record, error: e)
    end

    private

    attr_reader :task, :author, :params
  end
end

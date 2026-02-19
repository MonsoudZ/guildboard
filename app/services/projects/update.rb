module Projects
  class Update
    STALE_MESSAGE = "Project was changed by another user. Reload and try again."

    def self.call(project:, actor:, params:)
      new(project:, actor:, params:).call
    end

    def initialize(project:, actor:, params:)
      @project = project
      @actor = actor
      @params = params
    end

    def call
      DatabaseRole.write do
        ActiveRecord::Base.transaction do
          project.update!(params)
          ActivityLogger.log!(
            organization: project.organization,
            actor:,
            event_type: "project.updated",
            subject: project,
            metadata: { changed_fields: project.saved_changes.except("updated_at").keys }
          )
          Observability::StructuredLogger.log(
            event: "project.updated",
            actor:,
            organization: project.organization,
            project:,
            metadata: { changed_fields: project.saved_changes.except("updated_at").keys }
          )
        end
      end

      ServiceResult.new(record: project)
    rescue ActiveRecord::StaleObjectError
      project.errors.add(:base, STALE_MESSAGE)
      ServiceResult.new(record: project, error: :stale)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.new(record: e.record, error: e)
    end

    private

    attr_reader :project, :actor, :params
  end
end

module Projects
  class Create
    def self.call(organization:, actor:, params:)
      new(organization:, actor:, params:).call
    end

    def initialize(organization:, actor:, params:)
      @organization = organization
      @actor = actor
      @params = params
    end

    def call
      @project = organization.projects.new(params)

      DatabaseRole.write do
        ActiveRecord::Base.transaction do
          @project.save!
          ActivityLogger.log!(
            organization:,
            actor:,
            event_type: "project.created",
            subject: @project,
            metadata: { key: @project.key, name: @project.name, status: @project.status }
          )
          Observability::StructuredLogger.log(
            event: "project.created",
            actor:,
            organization:,
            project: @project,
            metadata: { key: @project.key, status: @project.status }
          )
        end
      end

      ServiceResult.new(record: @project)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.new(record: @project || e.record, error: e)
    end

    private

    attr_reader :organization, :actor, :params
  end
end

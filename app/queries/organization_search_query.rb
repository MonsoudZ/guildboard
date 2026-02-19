class OrganizationSearchQuery
  PER_PAGE = 20
  Result = Data.define(:query, :page, :projects, :tasks, :more_projects, :more_tasks)

  def self.call(organization:, query:, page: 1)
    new(organization:, query:, page:).call
  end

  def initialize(organization:, query:, page:)
    @organization = organization
    @query = query.to_s.strip
    @page = [ page.to_i, 1 ].max
  end

  def call
    return empty_result if query.blank?

    projects, more_projects = DatabaseRole.read { paginate(project_scope) }
    tasks, more_tasks = DatabaseRole.read { paginate(task_scope) }

    Result.new(
      query:,
      page:,
      projects:,
      tasks:,
      more_projects:,
      more_tasks:
    )
  end

  private

  attr_reader :organization, :query, :page

  def empty_result
    Result.new(
      query:,
      page:,
      projects: [],
      tasks: [],
      more_projects: false,
      more_tasks: false
    )
  end

  def paginate(scope)
    records = scope.limit(PER_PAGE + 1).offset(offset).to_a
    [ records.first(PER_PAGE), records.size > PER_PAGE ]
  end

  def project_scope
    organization.projects
                .where("LOWER(projects.name) LIKE :pattern OR LOWER(projects.key) LIKE :pattern OR LOWER(projects.description) LIKE :pattern",
                       pattern:)
                .order(project_rank_sql)
  end

  def task_scope
    Task.joins(:project)
        .includes(:project, :assignee)
        .where(projects: { organization_id: organization.id })
        .where("LOWER(tasks.title) LIKE :pattern OR LOWER(tasks.description) LIKE :pattern", pattern:)
        .order(task_rank_sql)
  end

  def project_rank_sql
    quoted = ActiveRecord::Base.connection.quote(query.downcase)
    Arel.sql("CASE WHEN LOWER(projects.key) = #{quoted} THEN 0 WHEN LOWER(projects.name) = #{quoted} THEN 1 ELSE 100 END, projects.updated_at DESC")
  end

  def task_rank_sql
    quoted = ActiveRecord::Base.connection.quote(query.downcase)
    Arel.sql("CASE WHEN LOWER(tasks.title) = #{quoted} THEN 0 ELSE 100 END, tasks.updated_at DESC")
  end

  def pattern
    @pattern ||= "%#{ActiveRecord::Base.sanitize_sql_like(query.downcase)}%"
  end

  def offset
    (page - 1) * PER_PAGE
  end
end

class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_organization
  before_action :ensure_membership!
  before_action :set_project, only: [ :show, :update ]

  def index
    projects = @organization.projects.order(:name)
    render json: { projects: projects.map { |project| project_payload(project) } }
  end

  def show
    render json: { project: project_payload(@project) }
  end

  def create
    result = Projects::Create.call(
      organization: @organization,
      actor: current_api_user,
      params: project_params
    )

    if result.success?
      render json: { project: project_payload(result.record) }, status: :created
    else
      render_validation_errors(result.record)
    end
  end

  def update
    result = Projects::Update.call(
      project: @project,
      actor: current_api_user,
      params: project_params
    )

    if result.success?
      render json: { project: project_payload(result.record) }
    else
      render_validation_errors(result.record)
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:id])
  end

  def ensure_membership!
    authorize_api_policy!(@organization, :manage_projects)
  end

  def project_params
    params.expect(project: [ :name, :key, :description, :status, :lock_version ])
  end

  def project_payload(project)
    {
      id: project.id,
      organization_id: project.organization_id,
      key: project.key,
      name: project.name,
      description: project.description,
      status: project.status,
      lock_version: project.lock_version
    }
  end
end

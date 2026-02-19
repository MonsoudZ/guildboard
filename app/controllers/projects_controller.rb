class ProjectsController < ApplicationController
  before_action :set_organization
  before_action :set_project, only: [ :show, :edit, :update ]
  before_action :authorize_membership!
  before_action :ensure_project_writable!, only: [ :edit, :update ]

  def show
    @tasks = @project.tasks.includes(:assignee).recent
  end

  def new
    @project = @organization.projects.new
  end

  def create
    result = Projects::Create.call(organization: @organization, actor: current_user, params: project_params)
    @project = result.record

    if result.success?
      redirect_to organization_project_path(@organization, @project), notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    result = Projects::Update.call(project: @project, actor: current_user, params: project_params)
    @project = result.record

    if result.success?
      redirect_to organization_project_path(@organization, @project), notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:id])
  end

  def project_params
    params.expect(project: [ :name, :key, :description, :status, :lock_version ])
  end

  def authorize_membership!
    authorize_policy!(@organization, :manage_projects, fallback: organizations_path)
  end

  def ensure_project_writable!
    return if @project.writable?

    redirect_to organization_project_path(@organization, @project), alert: "Archived projects are read-only."
  end
end

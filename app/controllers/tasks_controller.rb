class TasksController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_task, only: [ :show, :edit, :update ]
  before_action :authorize_membership!
  before_action :ensure_project_writable!, only: [ :new, :create, :edit, :update ]

  def show
    @task_comment = @task.task_comments.new
    @task_comments = @task.task_comments.includes(:author).order(created_at: :asc)
  end

  def new
    @task = @project.tasks.new
    @members = @organization.users.order(:name)
  end

  def create
    result = Tasks::Create.call(project: @project, creator: current_user, params: task_params)
    @task = result.record
    @members = @organization.users.order(:name)

    if result.success?
      redirect_to organization_project_task_path(@organization, @project, @task), notice: "Task created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @members = @organization.users.order(:name)
  end

  def update
    @members = @organization.users.order(:name)
    result = Tasks::Update.call(task: @task, actor: current_user, params: task_params)
    @task = result.record

    if result.success?
      redirect_to organization_project_task_path(@organization, @project, @task), notice: "Task updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.expect(task: [ :title, :description, :status, :priority, :due_on, :assignee_id, :lock_version ])
  end

  def authorize_membership!
    authorize_policy!(@organization, :manage_tasks, fallback: organizations_path)
  end

  def ensure_project_writable!
    return if @project.writable?

    redirect_to organization_project_path(@organization, @project), alert: "Archived projects are read-only."
  end
end

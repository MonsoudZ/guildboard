class Api::V1::TasksController < Api::V1::BaseController
  before_action :set_organization
  before_action :ensure_membership!
  before_action :set_project
  before_action :set_task, only: [ :show, :update ]

  def index
    tasks = @project.tasks.includes(:assignee).recent
    render json: { tasks: tasks.map { |task| task_payload(task) } }
  end

  def show
    render json: { task: task_payload(@task) }
  end

  def create
    result = Tasks::Create.call(
      project: @project,
      creator: current_api_user,
      params: task_params
    )

    if result.success?
      render json: { task: task_payload(result.record) }, status: :created
    else
      render_validation_errors(result.record)
    end
  end

  def update
    result = Tasks::Update.call(
      task: @task,
      actor: current_api_user,
      params: task_params
    )

    if result.success?
      render json: { task: task_payload(result.record) }
    else
      render_validation_errors(result.record)
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

  def ensure_membership!
    authorize_api_policy!(@organization, :manage_tasks)
  end

  def task_params
    params.expect(task: [ :title, :description, :status, :priority, :due_on, :assignee_id, :lock_version ])
  end

  def task_payload(task)
    {
      id: task.id,
      project_id: task.project_id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      due_on: task.due_on,
      assignee_id: task.assignee_id,
      creator_id: task.creator_id,
      lock_version: task.lock_version
    }
  end
end

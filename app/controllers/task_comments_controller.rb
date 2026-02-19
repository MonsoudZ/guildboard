class TaskCommentsController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_task
  before_action :authorize_membership!
  before_action :ensure_project_writable!, only: :create

  def create
    result = TaskComments::Create.call(task: @task, author: current_user, params: task_comment_params)
    @task_comment = result.record

    if result.success?
      redirect_to organization_project_task_path(@organization, @project, @task), notice: "Comment added."
    else
      redirect_to organization_project_task_path(@organization, @project, @task), alert: @task_comment.errors.full_messages.to_sentence
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
    @task = @project.tasks.find(params[:task_id])
  end

  def task_comment_params
    params.expect(task_comment: [ :body ])
  end

  def authorize_membership!
    authorize_policy!(@organization, :manage_tasks, fallback: organizations_path)
  end

  def ensure_project_writable!
    return if @project.writable?

    redirect_to organization_project_path(@organization, @project), alert: "Archived projects are read-only."
  end
end

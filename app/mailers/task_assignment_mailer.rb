class TaskAssignmentMailer < ApplicationMailer
  def assigned
    @task = params[:task]
    @recipient = params[:recipient]
    @organization = @task.project.organization

    mail to: @recipient.email, subject: "Assigned to task: #{@task.title}"
  end
end

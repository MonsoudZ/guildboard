class TaskDigestMailer < ApplicationMailer
  def due_digest
    @user = params[:user]
    @tasks = params[:tasks]
    @for_date = params[:for_date]

    mail to: @user.email, subject: "Task digest for #{@for_date}"
  end
end

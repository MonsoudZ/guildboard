# Preview all emails at http://localhost:3000/rails/mailers/task_assignment_mailer
class TaskAssignmentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/task_assignment_mailer/assigned
  def assigned
    task = Task.first || Task.new(title: "Preview task", project: Project.first || Project.new(name: "Preview", key: "PREVIEW", organization: Organization.first || Organization.new(name: "Org", slug: "org")))
    recipient = User.first || User.new(name: "Preview Recipient", email: "recipient@example.test")
    TaskAssignmentMailer.with(task:, recipient:).assigned
  end
end

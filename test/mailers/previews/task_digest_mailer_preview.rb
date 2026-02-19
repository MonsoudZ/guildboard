# Preview all emails at http://localhost:3000/rails/mailers/task_digest_mailer
class TaskDigestMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/task_digest_mailer/due_digest
  def due_digest
    user = User.first || User.new(name: "Preview User", email: "preview@example.test")
    tasks = Task.limit(3).to_a
    TaskDigestMailer.with(user:, tasks:, for_date: Date.current).due_digest
  end
end

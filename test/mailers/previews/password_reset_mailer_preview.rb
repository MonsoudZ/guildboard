# Preview all emails at http://localhost:3000/rails/mailers/password_reset_mailer
class PasswordResetMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/password_reset_mailer/reset
  def reset
    PasswordResetMailer.with(user: User.first || User.new(name: "Preview User", email: "preview@example.test"), token: "preview-token").reset
  end
end

class PasswordResetMailer < ApplicationMailer
  def reset
    @user = params[:user]
    @token = params[:token]
    @reset_url = edit_password_reset_url(@token)

    mail to: @user.email, subject: "Reset your GuildBoard password"
  end
end

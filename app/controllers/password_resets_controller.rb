require "digest"

class PasswordResetsController < ApplicationController
  skip_before_action :require_authentication
  before_action :set_reset_token, only: [ :edit, :update ]

  def new
  end

  def create
    normalized_email = params[:email].to_s.strip.downcase
    user = User.find_by(email: normalized_email)

    if user.present?
      token = PasswordResetToken.issue_for(user)
      PasswordResetMailer.with(user:, token: token.raw_token).reset.deliver_later
      AuditLogger.log!(action: "auth.password_reset_requested", actor: user, metadata: { success: true }, request:)
    end

    Observability::StructuredLogger.log(
      event: "auth.password_reset.requested",
      request:,
      actor: user,
      metadata: {
        principal_sha256: Digest::SHA256.hexdigest(normalized_email),
        matched_user: user.present?
      }
    )

    redirect_to new_session_path, notice: "If that email exists, we have sent password reset instructions."
  end

  def edit
  end

  def update
    password_params = params.expect(user: [ :password, :password_confirmation ])
    user = @password_reset_token.user

    User.transaction do
      user.update!(password_params)
      @password_reset_token.consume!
      user.invalidate_all_sessions!
      AuditLogger.log!(
        action: "auth.password_reset_completed",
        actor: user,
        metadata: { token_id: @password_reset_token.id },
        request:
      )
      Observability::StructuredLogger.log(
        event: "auth.password_reset.completed",
        request:,
        actor: user,
        metadata: { token_id: @password_reset_token.id }
      )
    end

    start_session!(user.reload)
    redirect_to root_path, notice: "Password has been reset."
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = user.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_entity
  end

  private

  def set_reset_token
    @password_reset_token = PasswordResetToken.find_active_by_raw_token(params[:token])
    return if @password_reset_token.present?

    redirect_to new_password_reset_path, alert: "That reset link is invalid or has expired."
  end
end

require "digest"

class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]

  def new
    if signed_in?
      redirect_to root_path, notice: "You are already signed in."
    end
  end

  def create
    normalized_email = params[:email].to_s.strip.downcase
    user = User.find_by(email: normalized_email)

    if user&.authenticate(params[:password].to_s)
      start_session!(user)
      AuditLogger.log!(action: "auth.sign_in", actor: user, metadata: { success: true }, request:)
      Observability::StructuredLogger.log(
        event: "auth.sign_in.succeeded",
        request:,
        actor: user,
        metadata: { success: true }
      )
      redirect_to root_path, notice: "Welcome back, #{user.name}."
    else
      AuditLogger.log!(
        action: "auth.sign_in_failed",
        actor: user,
        metadata: { email_sha256: Digest::SHA256.hexdigest(normalized_email) },
        request:
      )
      Observability::StructuredLogger.log(
        event: "auth.sign_in.failed",
        request:,
        actor: user,
        metadata: { principal_sha256: Digest::SHA256.hexdigest(normalized_email), success: false }
      )
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    actor = current_user
    terminate_session!
    if actor
      AuditLogger.log!(action: "auth.sign_out", actor:, metadata: { success: true }, request:)
      Observability::StructuredLogger.log(event: "auth.sign_out", request:, actor:, metadata: { success: true })
    end
    redirect_to new_session_path, notice: "You have been signed out."
  end
end

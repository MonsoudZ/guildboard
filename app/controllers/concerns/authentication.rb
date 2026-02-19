module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    helper_method :current_user, :signed_in?
  end

  private

  def set_current_user
    user = User.find_by(id: session[:user_id])

    if user && session.key?(:session_version) && session[:session_version].to_i == user.session_version
      Current.user = user
    else
      Current.user = nil
      terminate_session! if session[:user_id].present?
    end
  end

  def current_user
    Current.user
  end

  def signed_in?
    current_user.present?
  end

  def require_authentication
    return if signed_in?

    redirect_to new_session_path, alert: "Please sign in to continue."
  end

  def start_session!(user)
    reset_session
    session[:user_id] = user.id
    session[:session_version] = user.session_version
    Current.user = user
  end

  def terminate_session!
    reset_session
    Current.user = nil
  end
end

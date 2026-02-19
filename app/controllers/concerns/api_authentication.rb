module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    attr_reader :current_api_user
  end

  private

  def require_api_authentication
    token = bearer_token
    api_token = ApiToken.find_active_by_raw_token(token)

    unless api_token
      Observability::StructuredLogger.log(
        event: "api.auth.failed",
        request:,
        metadata: { reason: "missing_or_invalid_bearer_token" }
      )
      render json: { error: "unauthorized" }, status: :unauthorized
      return
    end

    @current_api_user = api_token.user
    Observability::StructuredLogger.log(event: "api.auth.succeeded", request:, actor: @current_api_user)
    api_token.mark_used!
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    header.start_with?("Bearer ") ? header.delete_prefix("Bearer ").strip : ""
  end
end

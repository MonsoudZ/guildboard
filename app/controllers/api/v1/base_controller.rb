class Api::V1::BaseController < ActionController::API
  include ApiAuthentication

  before_action :require_api_authentication

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    render json: { error: "not_found" }, status: :not_found
  end

  def render_forbidden
    render json: { error: "forbidden" }, status: :forbidden
  end

  def authorize_api_policy!(record, action)
    policy = "#{record.class}Policy".constantize.new(current_api_user, record)
    return if policy.public_send("#{action}?")

    render_forbidden
  end

  def render_validation_errors(record)
    errors = record.errors.map { |error| { field: error.attribute, message: error.message } }
    render json: { errors: }, status: :unprocessable_entity
  end
end

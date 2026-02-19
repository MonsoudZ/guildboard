class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_authentication
  around_action :with_observability_context

  private

  def with_observability_context
    Current.request_id = request.request_id
    yield
  rescue StandardError => e
    Observability::ErrorTracker.capture(
      exception: e,
      request:,
      actor: current_user,
      organization: observability_organization,
      project: observability_project,
      task: observability_task
    )
    raise
  ensure
    Current.reset
  end

  def authorize_policy!(record, action, fallback:)
    policy = policy_for(record)
    return if policy.public_send("#{action}?")

    redirect_to fallback, alert: "You do not have access to that resource."
  end

  def policy_for(record)
    "#{record.class}Policy".constantize.new(current_user, record)
  end

  def observability_organization
    @organization if defined?(@organization)
  end

  def observability_project
    @project if defined?(@project)
  end

  def observability_task
    @task if defined?(@task)
  end
end

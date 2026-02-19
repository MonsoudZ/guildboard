module Observability
  class ErrorTracker
    def self.capture(exception:, request:, actor: nil, organization: nil, project: nil, task: nil)
      classification = ErrorClassifier.classify(exception)
      metadata = {
        controller: request.params["controller"],
        action: request.params["action"]
      }.compact

      error_event = ErrorEvent.create!(
        classification:,
        error_class: exception.class.name,
        message: exception.message.to_s.truncate(500),
        request_id: request.request_id,
        path: request.path,
        http_method: request.request_method,
        user: actor,
        organization:,
        metadata:
      )

      StructuredLogger.log(
        event: "request.error",
        level: :error,
        request:,
        actor:,
        organization:,
        project:,
        task:,
        metadata: {
          classification:,
          error_event_id: error_event.id,
          error_class: exception.class.name
        }
      )

      error_event
    rescue StandardError => tracker_error
      StructuredLogger.log(
        event: "error_tracker.failure",
        level: :error,
        request:,
        actor:,
        organization:,
        metadata: {
          tracker_error_class: tracker_error.class.name,
          tracker_error_message: tracker_error.message
        }
      )
      nil
    end
  end
end

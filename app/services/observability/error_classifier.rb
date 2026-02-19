module Observability
  class ErrorClassifier
    ERROR_CLASSIFICATIONS = {
      ActiveRecord::RecordNotFound => "record_not_found",
      ActiveRecord::RecordInvalid => "record_invalid",
      ActiveRecord::StaleObjectError => "stale_object",
      ActiveRecord::ReadOnlyError => "read_only_violation",
      ActionController::ParameterMissing => "bad_request"
    }.freeze

    def self.classify(exception)
      ERROR_CLASSIFICATIONS.each do |exception_class, classification|
        return classification if exception.is_a?(exception_class)
      end

      "unhandled"
    end
  end
end

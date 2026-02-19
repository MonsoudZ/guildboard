require "json"

module Observability
  class StructuredLogger
    FILTERED_KEY_PATTERN = /(password|token|secret|authorization|cookie|email|digest)/i
    FILTERED_VALUE = "[FILTERED]".freeze

    def self.log(event:, level: :info, request: nil, request_id: nil, actor: nil, organization: nil, project: nil, task: nil, metadata: {})
      payload = {
        timestamp: Time.current.utc.iso8601(6),
        event:,
        request_id: request_id || request&.request_id || Current.request_id,
        actor_id: actor&.id,
        organization_id: organization&.id,
        project_id: project&.id,
        task_id: task&.id,
        metadata: sanitize(metadata)
      }.compact

      Rails.logger.public_send(level, payload.to_json)
      payload
    end

    def self.sanitize(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), result|
          result[key.to_s] = filtered_key?(key) ? FILTERED_VALUE : sanitize(nested_value)
        end
      when Array
        value.map { |nested_value| sanitize(nested_value) }
      else
        value
      end
    end

    def self.filtered_key?(key)
      key.to_s.match?(FILTERED_KEY_PATTERN)
    end
    private_class_method :filtered_key?
  end
end

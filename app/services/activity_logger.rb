class ActivityLogger
  def self.log!(organization:, actor:, event_type:, subject:, metadata: {})
    ActivityEvent.create!(
      organization:,
      actor:,
      event_type:,
      subject:,
      metadata:
    )
  end
end

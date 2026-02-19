class AuditLogger
  def self.log!(action:, actor: nil, organization: nil, auditable: nil, metadata: {}, request: nil)
    AuditLog.create!(
      action:,
      actor:,
      organization:,
      auditable:,
      metadata:,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end
end

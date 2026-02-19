class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :organization, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true
  validates :metadata, presence: true

  scope :recent, -> { order(created_at: :desc) }

  before_update :prevent_mutation
  before_destroy :prevent_mutation

  private

  def prevent_mutation
    errors.add(:base, "Audit logs are immutable")
    throw :abort
  end
end

class TaskComment < ApplicationRecord
  include SoftDeletable

  belongs_to :task
  belongs_to :author, class_name: "User", inverse_of: :task_comments

  validates :body, presence: true, length: { maximum: 1000 }
  validate :author_has_membership
  validate :project_is_writable

  private

  def author_has_membership
    return if author_id.blank?

    organization_id = task&.project&.organization_id
    return if organization_id.blank?
    return if Membership.exists?(user_id: author_id, organization_id:)

    errors.add(:author, "must be a member of the task organization")
  end

  def project_is_writable
    return if task.blank? || task.project.blank? || task.project.writable?

    errors.add(:task, "belongs to an archived project")
  end
end

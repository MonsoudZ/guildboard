class Task < ApplicationRecord
  include SoftDeletable

  ALLOWED_STATUS_TRANSITIONS = {
    "todo" => %w[ in_progress blocked ],
    "in_progress" => %w[ blocked done ],
    "blocked" => %w[ in_progress ],
    "done" => []
  }.freeze

  belongs_to :project
  belongs_to :creator, class_name: "User", inverse_of: :created_tasks
  belongs_to :assignee, class_name: "User", inverse_of: :assigned_tasks
  has_many :task_comments, dependent: :destroy

  enum :status, { todo: 0, in_progress: 1, blocked: 2, done: 3 }, default: :todo, validate: true
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }, default: :medium, validate: true

  validates :title, presence: true, length: { maximum: 160 }
  validate :creator_has_membership
  validate :assignee_has_membership
  validate :project_is_writable
  validate :status_transition_is_allowed, if: :will_save_change_to_status?

  scope :recent, -> { order(updated_at: :desc) }
  scope :open_statuses, -> { where.not(status: statuses[:done]) }

  private

  def creator_has_membership
    return if creator_id.blank? || project.blank?
    return if Membership.exists?(user_id: creator_id, organization_id: project.organization_id)

    errors.add(:creator, "must be a member of the project organization")
  end

  def assignee_has_membership
    return if assignee_id.blank? || project.blank?
    return if Membership.exists?(user_id: assignee_id, organization_id: project.organization_id)

    errors.add(:assignee, "must be a member of the project organization")
  end

  def project_is_writable
    return if project.blank? || project.writable?

    errors.add(:project, "is archived and read-only")
  end

  def status_transition_is_allowed
    return if new_record?

    from, to = status_change_to_be_saved
    return if from == to

    allowed = ALLOWED_STATUS_TRANSITIONS.fetch(from, [])
    return if allowed.include?(to)

    errors.add(:status, "cannot transition from #{from.humanize} to #{to.humanize}")
  end
end

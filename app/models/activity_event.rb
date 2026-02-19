class ActivityEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :actor, class_name: "User"
  belongs_to :subject, polymorphic: true

  validates :event_type, presence: true
  validates :metadata, presence: true

  scope :recent, -> { order(created_at: :desc) }

  before_update :prevent_mutation
  before_destroy :prevent_mutation

  def summary
    case event_type
    when "project.created"
      "Created project #{metadata['key'] || subject_label}"
    when "project.updated"
      "Updated project #{subject_label}"
    when "task.created"
      "Created task #{metadata['title'] || subject_label}"
    when "task.updated"
      "Updated task #{subject_label}"
    when "task.comment_added"
      "Added a comment on #{subject_label}"
    when "organization.invitation_sent"
      "Sent invitation to #{metadata['email']}"
    when "organization.invitation_accepted"
      "Accepted invitation for #{metadata['email']}"
    else
      event_type.humanize
    end
  end

  private

  def prevent_mutation
    errors.add(:base, "Activity events are immutable")
    throw :abort
  end

  def subject_label
    case subject
    when Project
      "#{subject.key} - #{subject.name}"
    when Task
      subject.title
    when OrganizationInvitation
      subject.email
    else
      subject.to_s
    end
  end
end

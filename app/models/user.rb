class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_one :notification_preference, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :activity_events, foreign_key: :actor_id, inverse_of: :actor, dependent: :restrict_with_exception
  has_many :audit_logs, foreign_key: :actor_id, inverse_of: :actor, dependent: :restrict_with_exception
  has_many :sent_organization_invitations, class_name: "OrganizationInvitation", foreign_key: :invited_by_id, inverse_of: :invited_by, dependent: :nullify
  has_many :accepted_organization_invitations, class_name: "OrganizationInvitation", foreign_key: :accepted_by_id, inverse_of: :accepted_by, dependent: :nullify
  has_many :created_tasks, class_name: "Task", foreign_key: :creator_id, inverse_of: :creator, dependent: :restrict_with_exception
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :restrict_with_exception
  has_many :task_comments, class_name: "TaskComment", foreign_key: :author_id, inverse_of: :author, dependent: :restrict_with_exception

  after_create :ensure_notification_preference!
  before_validation :normalize_email

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, if: -> { password.present? }
  validates :session_version, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def invalidate_all_sessions!
    increment!(:session_version)
  end

  def digest_notifications_enabled?
    notification_preference.nil? || notification_preference.digest_enabled?
  end

  def assignment_notifications_enabled?
    notification_preference.nil? || notification_preference.assignment_enabled?
  end

  private

  def ensure_notification_preference!
    create_notification_preference! unless notification_preference
  end

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end

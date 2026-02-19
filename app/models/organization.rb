class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :projects, dependent: :destroy
  has_many :organization_invitations, dependent: :destroy
  has_many :activity_events, dependent: :destroy
  has_many :audit_logs, dependent: :restrict_with_exception

  before_validation :normalize_slug

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z0-9-]+\z/ }

  private

  def normalize_slug
    self.slug = slug.to_s.parameterize
  end
end

class Project < ApplicationRecord
  include SoftDeletable

  belongs_to :organization
  has_many :tasks, dependent: :destroy

  enum :status, { active: 0, archived: 1 }, default: :active, validate: true

  before_validation :normalize_key

  validates :name, presence: true, length: { maximum: 120 }
  validates :key, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/ }

  def writable?
    active?
  end

  private

  def normalize_key
    self.key = key.to_s.upcase
  end
end

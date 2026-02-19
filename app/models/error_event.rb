class ErrorEvent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :organization, optional: true

  validates :classification, presence: true, length: { maximum: 80 }
  validates :error_class, presence: true, length: { maximum: 200 }
  validates :message, presence: true, length: { maximum: 500 }

  scope :recent, -> { order(created_at: :desc) }
end

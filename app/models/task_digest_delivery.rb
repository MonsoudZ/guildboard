class TaskDigestDelivery < ApplicationRecord
  belongs_to :user

  validates :delivered_on, presence: true
  validates :delivered_on, uniqueness: { scope: :user_id }
end

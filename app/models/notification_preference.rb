class NotificationPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :digest_enabled, inclusion: { in: [ true, false ] }
  validates :assignment_enabled, inclusion: { in: [ true, false ] }
end

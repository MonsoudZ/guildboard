class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { member: 0, manager: 1, owner: 2 }, default: :member, validate: true

  validates :user_id, uniqueness: { scope: :organization_id }
end

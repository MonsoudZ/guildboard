class ApiToken < ApplicationRecord
  TTL = 90.days

  belongs_to :user

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  attr_reader :raw_token

  def self.issue_for(user, name: "default", expires_at: TTL.from_now)
    raw_token = SecureRandom.urlsafe_base64(32)
    token = create!(
      user:,
      name:,
      token_digest: digest(raw_token),
      expires_at:
    )
    token.instance_variable_set(:@raw_token, raw_token)
    token
  end

  def self.find_active_by_raw_token(raw_token)
    find_by(token_digest: digest(raw_token))&.tap do |token|
      return nil unless token&.active?
    end
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def mark_used!
    update_column(:last_used_at, Time.current)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end

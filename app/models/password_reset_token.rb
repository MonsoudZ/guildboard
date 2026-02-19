class PasswordResetToken < ApplicationRecord
  TTL = 30.minutes

  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  attr_reader :raw_token

  def self.issue_for(user)
    transaction do
      user.password_reset_tokens.active.update_all(used_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
      raw_token = SecureRandom.urlsafe_base64(32)
      token = create!(
        user:,
        token_digest: digest(raw_token),
        expires_at: TTL.from_now
      )
      token.instance_variable_set(:@raw_token, raw_token)
      token
    end
  end

  def self.find_active_by_raw_token(raw_token)
    token = find_by(token_digest: digest(raw_token))
    return nil unless token&.active?

    token
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def active?
    used_at.nil? && expires_at.future?
  end

  def consume!
    update!(used_at: Time.current)
  end
end

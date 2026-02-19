class OrganizationInvitation < ApplicationRecord
  belongs_to :organization
  belongs_to :invited_by, class_name: "User"
  belongs_to :accepted_by, class_name: "User", optional: true

  TTL = 7.days

  enum :role, { member: 0, manager: 1, owner: 2 }, default: :member, validate: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :normalize_email

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }

  attr_reader :raw_token

  def self.issue!(organization:, invited_by:, email:, role:)
    transaction do
      normalized_email = email.to_s.strip.downcase

      organization.organization_invitations.pending
                  .where(email: normalized_email)
                  .update_all(expires_at: Time.current) # rubocop:disable Rails/SkipsModelValidations

      raw_token = SecureRandom.urlsafe_base64(32)
      invitation = create!(
        organization:,
        invited_by:,
        email: normalized_email,
        role:,
        token_digest: digest(raw_token),
        expires_at: TTL.from_now
      )
      invitation.instance_variable_set(:@raw_token, raw_token)
      invitation
    end
  end

  def self.find_pending_by_raw_token(raw_token)
    invitation = find_by(token_digest: digest(raw_token))
    return nil unless invitation&.pending?

    invitation
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def pending?
    accepted_at.nil? && expires_at.future?
  end

  def accept!(user:)
    update!(accepted_at: Time.current, accepted_by: user)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def method_missing(_name, *_args)
    false
  end

  def respond_to_missing?(_name, _include_private = false)
    true
  end

  private

  def membership_for(organization)
    return nil unless user

    Membership.find_by(user:, organization:)
  end
end

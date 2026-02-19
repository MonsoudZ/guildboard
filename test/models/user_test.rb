require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email before validation" do
    user = User.new(
      name: "Case Test",
      email: "  MIXED@Example.Test ",
      password: "password123456",
      password_confirmation: "password123456"
    )

    assert user.valid?
    assert_equal "mixed@example.test", user.email
  end

  test "requires a strong password length" do
    user = User.new(
      name: "Short Password",
      email: "short@example.test",
      password: "too-short",
      password_confirmation: "too-short"
    )

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "validates unique email_address" do
    user = User.new(
      email_address: users(:one).email_address.upcase,
      password: "password",
      password_confirmation: "password",
    )

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end
end

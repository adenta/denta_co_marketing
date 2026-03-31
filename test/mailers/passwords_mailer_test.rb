require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset uses the template default sender" do
    email = PasswordsMailer.reset(users(:one))

    assert_equal [ "no-reply@mail.denta.co" ], email.from
    assert_equal [ users(:one).email_address ], email.to
    assert_equal "Reset your password", email.subject
  end
end

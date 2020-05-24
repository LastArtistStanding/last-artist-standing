# frozen_string_literal: true

require 'test_helper'

class EmailVerificationTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  def setup
    user_data = { user: { name: 'name', email: 'g@g.com',
                          password: 'password',
                          password_confirmation: 'password' } }
    post users_path, xhr: true, params: user_data
    @user = User.find(session[:user_id])
  end

  test 'email verification' do
    # The user should not be verified until we use the verification link.
    assert_not @user.verified?
    assert_not @user.email_verified?

    # Verify that a verification email was sent.
    assert_equal 1, ActionMailer::Base.deliveries.size
    # Use a regex to figure out what the verification token was from the email sent.
    mail_body = ActionMailer::Base.deliveries[0].to_s
    digest = %r/email_verification\/(.{22})/.match(mail_body).captures[0]

    # Make sure the incorrect digest doesn't work.
    get email_verification_path(@user, 'bad digest')
    assert_redirected_to edit_user_path(@user)
    assert_not flash.empty?

    # Make sure we can view the email verification page.
    get email_verification_path(@user, digest)
    assert_template 'email_verifications/edit'

    # Verify our email address.
    post email_verification_path(@user, digest)
    assert_redirected_to root_path
    assert_not flash.empty?

    # The user should now be verified.
    @user.reload
    assert @user.verified?
    assert @user.email_verified?
  end
end

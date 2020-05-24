# frozen_string_literal: true

# Handles sending emails related to the user lifecycle: creating accounts and password resets.
class UserMailer < ApplicationMailer
  def email_verification(user, token)
    @user = user
    @token = token
    mail to: user.email,
         subject: "#{user.username}, please verify your email address for Do Art Daily"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'Do Art Daily - Password Reset'
  end
end

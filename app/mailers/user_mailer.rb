class UserMailer < ApplicationMailer

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Do Art Daily - Password Reset"
  end
end

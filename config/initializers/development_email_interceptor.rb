# frozen_string_literal: true

# Redirect emails in the development environment to the local user's Unix inbox using sendmail.
class DevelopmentEmailInterceptor
  def self.delivering_email(message)
    message.to = ["#{ENV['USER']}@localhost"]
  end
end

if ENV['REDIRECT_MAIL'] == 'unix'
  ActionMailer::Base.register_interceptor(DevelopmentEmailInterceptor)
end

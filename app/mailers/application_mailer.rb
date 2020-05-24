# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Do Art Daily <noreply@dad.gallery>'
  layout 'mailer'
end

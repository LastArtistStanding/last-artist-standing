class IncomingsMailbox < ApplicationMailbox
  def process
    mail_attachments
  end

  def mail_body
    mail.body.decoded
  end

  def mail_attachments
    mail.mail_attachments.each do |attachment|
      # your logic here
    end
  end
end

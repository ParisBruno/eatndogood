# frozen_string_literal: true

class AdminMailer < ApplicationMailer

  def notification_email(chef_name, receiver, from, subject, content, email_content_id)
    @receiver = receiver
    @email_body = content
    email_content = EmailContent.find_by(id: email_content_id)
    if email_content && email_content.attacment.attached?
      attachments[email_content.attacment.filename.to_s] = {
        mime_type: email_content.attacment.blob.content_type,
        content: email_content.attacment.blob.download
      }
    end
    
    mail(to: receiver, from: from,:subject => subject)
  end

  def inactive_guests_email(receiver, guests)
    @guests  = guests
    mail(to: receiver.email, subject: 'List of inactive guests')
  end
end

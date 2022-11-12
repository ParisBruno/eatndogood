# frozen_string_literal: true

class AdminMailer < ApplicationMailer

  def notification_email(current_app, chef_name, receiver, from, subject, content, email_content_id)
    current_user = User.find_by(email: from)
    @receiver = receiver
    @email_body = content
    email_content = EmailContent.find_by(id: email_content_id)
    if email_content && email_content.attacment.attached?
      attachments[email_content.attacment.filename.to_s] = {
        mime_type: email_content.attacment.blob.content_type,
        content: email_content.attacment.blob.download
      }
    end
    
    mail(to: receiver, from: current_app.main_admin&.email, subject: subject)
  end

  def inactive_guests_email(receiver, guests, current_app)
    @guests  = guests
    mail(from: current_app.main_admin&.email, to: receiver.email, subject: 'List of inactive guests')
  end

  def check_sendgrid_senders(current_user)
    if current_user.admin?
      url = URI("https://api.sendgrid.com/v3/marketing/senders")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
      request["Content-Type"] = 'application/json'
      
      response = http.request(request)
      return if response.read_body['errors'].present?

      senders = JSON.parse(response.read_body)
      senders_emails = []
      senders.each { |sender| senders_emails << sender['from']['email'] if sender['from'] && sender['verified']['status'] }

      senders_emails.include?(current_user.email)
    end
  end
end

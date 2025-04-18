class SslRenewalMailer < ApplicationMailer
 default from: 'noreply@example.com'

  def renewal_reminder(days_left)
    @days_left = days_left
    emails = [ 'kanchankamboj1020@gmail.com', 'brunofiuggi@gmail.com' ]
    mail(to: emails, subject: "SSL Expiry Reminder - #{days_left} days left")
  end
end

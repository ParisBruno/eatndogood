namespace :ssl do
 desc "Send SSL renewal reminders for itoprecipes"
  task send_reminder: :environment do
    app = App.find_by(slug: 'eatndogoodlive')

    expiry_date = app.ssl_renew_date + 3.months
    days_left = (expiry_date - Date.today).to_i

    if [10, 5, 1].include?(days_left)
      SslRenewalMailer.renewal_reminder(days_left).deliver_now
    end
  end
end

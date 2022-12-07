class ServiceMailer < ActionMailer::Base

  def send_booking_confirmation(current_app, slot)
    @slot = slot
    @day = week_days[slot.day.to_date.wday]
    mail(from: current_app.main_admin&.email, to: slot.email, subject: 'Reservation confirmation!')
  end

  def send_booking_admin_confirmation(current_app, current_app_user, slot)
    @slot = slot
    @day = week_days[slot.day.to_date.wday]
    admin_email = current_app.main_admin&.email
    emails = [admin_email]
    emails << current_app_user.email if current_app_user.manager?
    mail(from: admin_email, to: emails, subject: 'Reservation confirmation!')
  end

  private
  def week_days
    ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  end
end

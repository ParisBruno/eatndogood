# frozen_string_literal: true

class InactiveGuestsAdminNotificationWorker
  include Sidekiq::Worker

  def perform(*args)
    guests = User.inactive_guests
    return unless guests.any?

    # TODO: Who should receive this email?
    AdminMailer.inactive_guests_email(User.where(admin: true).first, guests).deliver_now
  end
end

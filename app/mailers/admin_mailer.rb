# frozen_string_literal: true

class AdminMailer < ApplicationMailer

  def notification_email(chef_name, receiver, text)
    @receiver = receiver
    @text = text
    mail(to: receiver.email, subject: "Hi! You have message from #{chef_name}")
  end

  def inactive_guests_email(receiver, guests)
    @guests  = guests
    mail(to: receiver.email, subject: 'List of inactive guests')
  end
end

# frozen_string_literal: true

class AdminMailer < ApplicationMailer

  def inactive_guests_email(reciever, guests)
    @guests  = guests
    mail(to: reciever.email, subject: 'List of inactive guests')
  end
end

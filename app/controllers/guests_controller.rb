# frozen_string_literal: true
class GuestsController < ApplicationController

  def index
    return redirect_to root_path unless current_user.chef?

    @guests = current_user.guests.paginate(page: params[:page], per_page: 5)
  end

  def send_emails
    text = params[:text]
    receivers = params[:receivers].present? ? params[:receivers] : current_user.guests
    return redirect_to root_path unless current_user.chef?

    return unless text.present?

    receivers.each do |receiver|
      AdminMailer.notification_email(current_user.full_name, receiver, text).deliver_now
    end
  end
end

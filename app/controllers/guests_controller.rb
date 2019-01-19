# frozen_string_literal: true
class GuestsController < ApplicationController

  def index
    return redirect_to root_path if current_user.guest? || current_user.chef?

    @guests = User.where(guest: true).paginate(page: params[:page], per_page: 5)
  end

  def new
    @guest = User.new

    @email = (params[:email].present?) ? Base64.decode64(params[:email]) : ''
    @user_id = (params[:id].present?) ? params[:id] : ''
  end

  def send_emails
    text = params[:text]
    receivers = params[:emails].present? ? params[:emails] : current_user.guests
    return redirect_to root_path if current_user.guest?

    return unless text.present?

    receivers.each do |receiver|
      AdminMailer.notification_email(current_user.full_name, receiver, text).deliver_now
    end
  end
end

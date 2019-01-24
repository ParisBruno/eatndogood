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

  def create
    @guest = User.create!(guest_params)
    if @guest
      sign_in(@guest)
      #send email to guest admin
      unless @guest.user_id.blank?
        #@guest.user_id is admin id
        @chef = User.where(id: @guest.user_id).first
        UserMailer.guest_create_email_to_admin(@chef.email, @guest).deliver if @chef
      end

      #add to mailchimp
      begin
        client = Mailchimp::API.new('f688f72e7f5b7bafdf077dc0b4b1ce28-us17')
        client.lists.subscribe('5d953a3d2b', {email: @guest[:email]}, {'FNAME' => @guest[:first_name], 'LNAME' => @guest[:last_name]})
      rescue Exception => e
        puts e
      end

      flash[:success] = I18n.t 'flash.you_registered_guest'
      redirect_to recipes_path(is_guest: :yes, iden: 'Guest')
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Recipe deleted successfully"
    redirect_to guests_path
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

  def guest_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :user_id)
  end

end

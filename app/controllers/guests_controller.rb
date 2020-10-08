# frozen_string_literal: true
class GuestsController < ApplicationController
  respond_to :html, :json

  protect_from_forgery prepend: true, with: :exception
  skip_before_action :verify_authenticity_token, only: [:send_emails]

  def index
    return redirect_to app_path(current_app) if current_app_user.guest?

    @keyword = params[:keyword].present? ? params[:keyword].strip : ''

    if @keyword.blank?
      @guests = current_app.users.guests.order('id desc').paginate(page: params[:page], per_page: 100)
      # @guests = User.where(guest: true).where(user_id: current_app_user.id).order('id desc').paginate(page: params[:page], per_page: 100)
    else
      @guests = current_app.users.guests.where('users.first_name LIKE ? or users.email LIKE ? or users.last_name LIKE ? or users.first_name LIKE ?', "%#{@keyword}%","%#{@keyword}%","%#{@keyword}%","%#{@keyword}%").order('id desc').paginate(page: params[:page], per_page: 100)
    end
    
    respond_to do |format|
      format.html { render :index }
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=guests.xlsx"
      }
    end

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
        raise @chef.inspect
        UserMailer.guest_create_email_to_admin(@chef.email, @guest).deliver_later if @chef
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
    content = params[:email_content][:content]
    subject = params[:subject]
    @email_content = EmailContent.create(email_params)
    receivers = params[:receivers].present? ? params[:receivers] : current_app_user.guests
    return redirect_to app_path(current_app) if current_app_user.guest?

    return unless content.present?

    upload_attachments

    receivers.split(',').each do |receiver|
      AdminMailer.notification_email(current_app_user.full_name, receiver, current_app_user.email, subject, content, @email_content.id).deliver_later
    end

    respond_to do |format|
      format.json { render json: @email_content.to_json }
    end
  end

  private

  def upload_attachments
    if params[:attachments]
      params[:attachments].each do |attachment|
        @email_content.attacment.attach(attachment)
      end
    end
  end

  def email_params
    params.require(:email_content).permit(:content)
  end

  def guest_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :user_id)
  end

end

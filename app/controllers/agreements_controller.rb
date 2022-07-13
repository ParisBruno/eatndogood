class AgreementsController < ApplicationController
  def create
    agreement = Agreement.new(agreement_params)
    if agreement.save
      cookies[:agreement] = true
      if current_app_user.nil?
        create_guest_user(agreement)
      else
        agreement.update(user_id: current_app_user.id)
      end
      AgreementMailer.copy_email(agreement, @current_app).deliver_now
      flash[:success] = "Agreement Successfully Submited and send copy of agreement to your email!"
      redirect_to app_style_path(@current_app, Style.agreement_style)
    end
  end

  private
  def agreement_params
    params.require(:agreement).permit(:email, :first_name, :last_name, :guardian_email, :guardian_first_name, :guardian_last_name, :style_id)
  end

  def create_guest_user(agreement)
    guest = User.find_by(email: agreement.email)
    if guest.nil?
      password = SecureRandom.hex(8)
      user = User.create(email: agreement.email, first_name: agreement.first_name, last_name: agreement.last_name, password: password, app_id: @current_app.id, guest: true)
      if user.save!
        agreement.update(user_id: user.id)
        UserMailer.guest_welcome_email(user, password, @current_app).deliver_now
      end
    end
  end
end

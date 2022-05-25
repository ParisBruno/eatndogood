class AgreementsController < ApplicationController
  def create
    agreement = Agreement.new(agreement_params)
    if agreement.save
      cookies[:agreement] = true
      AgreementMailer.copy_email(agreement).deliver_now
      flash[:success] = "Agreement Successfully Submited and send copy of agreement to your email!"
      redirect_to app_style_path(@current_app, Style.agreement_style)
    end
  end

  private
  def agreement_params
    params.require(:agreement).permit(:email, :first_name, :last_name, :guardian_email, :guardian_first_name, :guardian_last_name, :style_id)
  end
end

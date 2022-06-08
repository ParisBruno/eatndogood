class AgreementMailer < ActionMailer::Base

  def copy_email(agreement,current_app)
    @agreement = agreement
    mail(to: agreement.email, subject: 'RockyStepsWay agreement copy!')
    mail(from: current_app.admin_user)
  end
end
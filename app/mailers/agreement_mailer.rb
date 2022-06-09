class AgreementMailer < ActionMailer::Base

  def copy_email(agreement, current_app)
    @agreement = agreement
    mail(from: current_app.main_admin&.email, to: agreement.email, subject: 'RockyStepsWay agreement copy!')
  end
end

class AgreementMailer < ActionMailer::Base
  default :from => "bruno@itoprecipes.com"

  def copy_email(agreement)
    @agreement = agreement
    mail(to: agreement.email, subject: 'RockyStepsWay agreement copy!')
  end
end
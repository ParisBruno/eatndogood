class PasswordsController < Devise::PasswordsController

  protected
  def after_resetting_password_path_for(resource)
    url =  "/#{current_app.slug}/team/#{resource.id}"
    as = current_app.autosaves.where(form: url).last
    if as.present?
      payload = JSON.parse as.payload
      payload["10"]["value"] = params["app_user"]["password"]
      payload["11"]["value"] = params["app_user"]["password_confirmation"]
      as.update(payload: payload.to_json)
    end
    Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
  end
end
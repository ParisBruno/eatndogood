class PasswordsController < Devise::PasswordsController

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  protected
  def after_resetting_password_path_for(resource)
    url =  "/#{current_app.slug}/team/#{resource.id}"
    as = current_app.autosaves.where(form: url).last
    if as.present?
      payload = JSON.parse as.payload
      if params[:app].nil?
        payload["14"]["value"] = params["user"]["password"]
        payload["15"]["value"] = params["user"]["password_confirmation"]
      else
        payload["14"]["value"] = params["app_user"]["password"]
        payload["15"]["value"] = params["app_user"]["password_confirmation"]
      end
      as.update(payload: payload.to_json)
    end
    Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
  end
end

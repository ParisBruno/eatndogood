class ApplicationController < ActionController::Base
  include LocaleDefinition
  protect_from_forgery with: :exception
  helper_method :current_chef, :logged_in?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_header_data

  def current_chef
    @current_chef ||= Chef.find(session[:chef_id]) if session[:chef_id]
  end

  def logged_in?
    current_user.chef? || current_user.admin?
  end

  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to root_path
    end
  end

  protected

  def require_logged_in
    if current_user.nil?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    session[:chef_id] = current_user.chef_id
    recipes_path
  end

  def configure_permitted_parameters
    permit_attrs(%i[first_name last_name])
  end

  def permit_attrs(attrs)
    %i[sign_up account_update].each do |action|
      devise_parameter_sanitizer.permit(action, keys: attrs)
    end
  end

  def set_header_data
    @ingredients = Ingredient.all
    @allergens = Allergen.all
  end
end

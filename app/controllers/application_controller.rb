class ApplicationController < ActionController::Base
  include LocaleDefinition
  protect_from_forgery with: :exception
  helper_method :current_chef, :logged_in?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_header_data

  def current_chef
    @current_chef ||= Chef.find(current_user.chef_info.id) if current_user && !current_user.chef_info.nil?
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

  def set_admin_id
    @admin_id = params[:admin_id].present? if params[:admin_id]

    @admin_id = User.friendly.find(params[:user]) if(@admin_id.nil? && !params[:user].nil?)

    @admin_id =  current_user.id if(@admin_id.nil? && !current_user.nil? && current_user.admin?)

      
    @admin_id =  User.where(admin: true).first.id
  end

  def require_admin
    if !logged_in? || (logged_in? and !current_user.admin?)
      flash[:danger] = "Only admin users can perform that action"
      redirect_to ingredients_path
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
    user_id = !current_user.nil? ? current_user.id : User.where(admin: true).first
    @ingredients = Ingredient.where(user_id: user_id)
    @allergens = Allergen.where(user_id: user_id)
    @styles = Style.where(user_id: user_id)
  end
end

class ChefsController < ApplicationController
  before_action :authenticate_app_user!
  before_action :set_user, only: [:edit, :update]
  before_action :set_chef, only: [:show, :destroy]
  before_action :require_same_user, only: [:edit, :update]
  before_action :require_admin, only: [:destroy]
  
  before_action :check_limit_chefs, only: [:new, :create]
  
  def index
    # @chefs = Chef.includes(:user).where(admin_id: @admin_id).order(admin: :desc).order(:created_at).paginate(page: params[:page], per_page: 5)
    users_id = current_app.users.pluck(:id)
    @chefs = Chef.where(user_id: users_id).order(:created_at).paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @user = User.new
    @user.build_chef_info
  end
  
  def create
    @user = User.new(chef_params)
    @user.guest = false
    @user.chef = true
    @user.app = current_app
    if @user.save
      delete_draft
      flash[:success] = "Welcome #{@user.full_name} to MyRecipes App!"
      redirect_to app_chef_path(current_app, @user.chef_info)
    else
        render 'new'
    end
    
  end
  
  def show
    @chef_recipes = @chef.recipes.paginate(page: params[:page], per_page: 5)
  end
  
  def edit
  end
  
  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:encrypted_password) if params[:user][:password].blank?
    user = User.find current_app_user.id

    if @user.update(chef_params)
      delete_draft(@user)
      bypass_sign_in @user if user.id == @user.id
      flash[:success] = "Your account was updated successfully"
      redirect_to [current_app,@user.chef_info]
    else
      render 'edit'
    end  
  end
  
  def destroy
    if !@chef.admin?
      @chef.destroy
      flash[:danger] = "Chef and all associated recipes have been deleted!"
      redirect_to app_chefs_path(current_app)
    else
       flash[:danger] = "Cannot delete chef admin account"
       redirect_to app_chef_path(current_app, @chef)
    end
  end
  
  private

  def check_limit_chefs
    plan = current_app.plan
    current_chefs_count = current_app.chefs.count
    if !plan.chefs_limit.nil? && (current_chefs_count >= plan.chefs_limit)
      flash[:danger] = "Your account has already reached limit the number of chefs. To add more chef, please upgrade your plan."
      redirect_to app_chefs_path(current_app)
    end
  end

  def slug=(value)
     if value.present?
       write_attribute(:slug, value)
     end
   end
  
  def chef_params
    # params.require(:chef).permit(:my_bio, :chef_avatar, user_attributes: [:first_name, :last_name, :email, 
    #                               :password, :password_confirmation])
    chef_info_permitted_attributes = Chef.globalize_attribute_names + [:chef_avatar, :admin_id, :id]
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :slug, chef_info_attributes: 
                                    chef_info_permitted_attributes, app_attributes: [:slug, :id])
  end

  def set_user
    # @user = User.includes(:chef_info).friendly.find(params[:id])
    @user = User.includes(:chef_info).find(params[:id])
  end

  def set_chef
    @chef = Chef.includes(:user).find params[:id]
  end
  
  def require_same_user
    if current_app_user.id != @user.id && !current_app_user.admin?
      flash[:danger] = "You can only edit or delete your own account"
      redirect_to app_chefs_path(current_app)
    end
  end
  
  def require_admin
    if logged_in? && !current_app_user.admin?
      flash[:danger] = "Only admin users can perform that action"
      redirect_to app_path(current_app)
    end
  end

  def delete_draft(user=nil)
    if user.nil?
      url = "/#{current_app.slug}/chefs"
    else
      url =  "/#{current_app.slug}/chefs/#{user.id}"
    end
    as = current_app.autosaves.where(form: url).first
    if as
      as.destroy
    end
  end
  
end
class ChefsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]
  before_action :set_chef, only: [:show, :destroy]
  before_action :require_same_user, only: [:edit, :update]
  before_action :require_admin, only: [:destroy]
  
  def index
    @chefs = Chef.includes(:user).where(admin_id: current_user.id).order(admin: :desc).order(created_at: :desc).paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @user = User.new
    @user.build_chef_info
  end
  
  def create
    @user = User.new(chef_params)
    if @user.save
      flash[:success] = "Welcome #{@user.full_name} to MyRecipes App!"
      redirect_to chef_path(@user.chef_info)
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
    user = User.find current_user.id
    if @user.update(chef_params)
      #bypass_sign_in user
      flash[:success] = "Your account was updated successfully"
      redirect_to @user.chef_info
    else
      render 'edit'
    end  
  end
  
  def destroy
    if !@chef.admin?
      @chef.destroy
      flash[:danger] = "Chef and all associated recipes have been deleted!"
      redirect_to chefs_path
    else
       flash[:danger] = "Cannot delete chef admin account"
       redirect_to chef_path(@chef)
    end
  end
  
  private
  
  def chef_params
    # params.require(:chef).permit(:my_bio, :chef_avatar, user_attributes: [:first_name, :last_name, :email, 
    #                               :password, :password_confirmation])
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, chef_info_attributes: 
                                    [:my_bio, :chef_avatar, :admin_id, :id])
  end

  def set_user
    @user = User.includes(:chef_info).find(params[:id])
  end

  def set_chef
    @chef = Chef.includes(:user).find params[:id]
  end
  
  def require_same_user
    if current_user != @user.id && !current_user.admin?
      flash[:danger] = "You can only edit or delete your own account"
      redirect_to chefs_path
    end
  end
  
  def require_admin
    if logged_in? && !current_user.admin?
      flash[:danger] = "Only admin users can perform that action"
      redirect_to root_path
    end
  end
  
end
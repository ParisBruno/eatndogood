class ChefsController < ApplicationController
  before_action :authenticate_based_on_app_presence, :except => [:index, :show]
  before_action :set_user, only: [:edit, :update]
  before_action :set_chef, only: [:show, :destroy]
  before_action :require_same_user, only: [:edit, :update]
  before_action :require_admin, only: [:destroy]
  before_action :set_team_member, only: [:admin, :managers, :staff]
  before_action :check_admin, only: [:admin]
  before_action :set_manager, only: [:managers]
  before_action :set_selected_languages, only: [:edit, :update]
  protect_from_forgery prepend: true, with: :exception
  skip_before_action :verify_authenticity_token
  
  def index
    # @chefs = Chef.includes(:user).where(admin_id: @admin_id).order(admin: :desc).order(:created_at).paginate(page: params[:page], per_page: 5)
    users_id = current_app.users.pluck(:id)
    @chefs = Chef.joins(:user).where(user_id: users_id).order('users.admin asc, users.manager desc').paginate(page: params[:page], per_page: 5)
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
      flash[:success] = t('chefs.account_created_successfully', full_name: @user.full_name)
      redirect_to app_route(app_chef_path(current_app, @user.chef_info))
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
    user = User.find @sessioned_user.id

    if @user.update(chef_params)
      delete_draft(@user)
      bypass_sign_in @user if user.id == @user.id
      flash[:success] = t('chefs.account_updated_successfully')
      current_app.reload
      redirect_to app_route(app_chef_path(current_app, @user.chef_info))
    else
      render 'edit'
    end
  end
  
  def destroy
    if !@chef.admin?
      @chef.destroy
      flash[:danger] = t('chefs.chef_and_all_associated_services_deleted')
      redirect_to app_route(app_chefs_path(current_app))
    else
       flash[:danger] = t('chefs.cannot_delete_chef_admin_account')
       redirect_to app_route(app_chef_path(current_app, @chef))
    end
  end

  def add_coupon
    coupon_code = CouponCode.find_or_initialize_by(title: params[:coupon_code][:title], chef_id: @sessioned_user.chef_info.id)
    coupon_percent_off = params[:coupon_code][:coupon_percent_off].present? ? params[:coupon_code][:coupon_percent_off] : 0
    coupon_amount_off = params[:coupon_code][:coupon_amount_off].present? ? params[:coupon_code][:coupon_amount_off] : 0
    coupon_code.assign_attributes(coupon_percent_off: coupon_percent_off, coupon_amount_off: coupon_amount_off, is_active: params[:coupon_code][:is_active])
    coupon_code.save!

    respond_to do |format|
      format.js
    end
  end

  def destroy_coupon
    coupon_code = CouponCode.find(params[:code_id])
    coupon_code.destroy

    respond_to do |format|
      format.js
    end
  end

  def add_fundrasing
    fundrasing_code = FundrasingCode.find_or_initialize_by(title: params[:fundrasing_code][:title], chef_id: @sessioned_user.chef_info.id)
    fundrasing_code.assign_attributes(is_active: params[:fundrasing_code][:is_active])
    fundrasing_code.save!

    respond_to do |format|
      format.js
    end
  end

  def destroy_fundrasing
    fundrasing_code = FundrasingCode.find(params[:code_id])
    fundrasing_code.destroy

    respond_to do |format|
      format.js
    end
  end

  def admin
    return redirect_to app_route(app_recipes_path(current_app)) if @admin_id != current_app.main_admin.chef_info.id

    render 'chefs/point_of_sales'
  end

  def managers
    render 'chefs/point_of_sales'
  end

  def staff
    return redirect_to app_route(app_recipes_path(current_app)) unless @staff_id

    @orders = Order.where(user_id: @staff_id).order(created_at: :desc)
    @manager = @sessioned_user.team_manager
    render 'chefs/point_of_sales'
  end
  
  private

  def slug=(value)
     if value.present?
       write_attribute(:slug, value)
     end
   end
  
  def chef_params
    # params.require(:chef).permit(:my_bio, :chef_avatar, user_attributes: [:first_name, :last_name, :email, 
    #                               :password, :password_confirmation])
    chef_info_permitted_attributes = Chef.globalize_attribute_names + [:chef_avatar, :admin_id, :id]
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :slug,
                                 :delivery_price, :is_home_delivery, :product_tax, :paypal_client_id, :paypal_client_secret, :manager, :title,
                                 :manager_id, :store_address, :phone, :greeting_message, :business_name, :stripe_publishable_key, :stripe_secret_key, selected_payment_methods: [],
                                 chef_info_attributes: chef_info_permitted_attributes, app_attributes: [:slug, :id, selected_languages: []])
  end

  def set_user
    # @user = User.includes(:chef_info).friendly.find(params[:id])
    @user = current_app.users.friendly.includes(:chef_info).find_by(slug: params[:id])
  end

  def set_chef
    @chef = current_app.chefs.friendly.includes(:user).find_by(slug: params[:id])
  end
  
  def require_same_user
    if @sessioned_user.id != @user.id && !@sessioned_user.admin?
      flash[:danger] = t('chefs.only_edit_or_delete_own_account')
      redirect_to app_route(app_chefs_path(current_app))
    end
  end
  
  def require_admin
    if logged_in? && !@sessioned_user.admin?
      flash[:danger] = t('flash.only_admin_users_action')
      redirect_to app_route(app_path(current_app))
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

  def set_manager
    @current_manger = current_app.users.managers.find_by(id: params[:manager_id])

    redirect_to app_route(app_recipes_path(current_app)) if @current_manger != @sessioned_user
  end

  def authenticate_based_on_app_presence
    params[:app].present? ? authenticate_app_user! : authenticate_user!
  end
end

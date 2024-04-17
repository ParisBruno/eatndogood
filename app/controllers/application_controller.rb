class ApplicationController < ActionController::Base
  include LocaleDefinition
  include ApplicationHelper
  protect_from_forgery with: :exception
  helper_method :current_chef, :logged_in?, :current_app
  # before_action :set_app, except: %i[send_emails destroy]
  before_action :verify_app
  before_action :check_app_user
  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :set_admin_id
  before_action :set_header_data
  before_action :current_cart
  before_action :set_devise_sender
  before_action :expire_service_slots

  def expire_service_slots
    service_slots = ServiceSlot.joins(:service).where(services: {app_id: current_app.id}, booked: true)
    expire_slots = service_slots.where('service_slots.end_time < ?', Time.now)
    expire_slots.update(booked: false)
  end

  def current_chef
    @current_chef ||= Chef.find(@sessioned_user.chef_info.id) if @sessioned_user && !@sessioned_user.chef_info.nil?
    raise @current_chef.inspect
  end

  def logged_in?
    @sessioned_user.chef? || @sessioned_user.admin?
  end

  def require_user
    if !logged_in?
      flash[:danger] = t('flash.you_must_be_logged_in')
      redirect_to app_route(app_path(current_app))
    end
  end

  def check_sendgrid_senders
    if @sessioned_user.admin?
      url = URI("https://api.sendgrid.com/v3/marketing/senders")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
      request["Content-Type"] = 'application/json'
      
      response = http.request(request)
      unless response.read_body['errors'].present?
        senders = JSON.parse(response.read_body)

        senders_emails = []
        senders.each { |sender| senders_emails << sender['from']['email'] if sender['from'] }

        add_sender_to_sendgrid unless senders_emails.include?(@sessioned_user.email)
      end
    end
  end

  def add_sender_to_sendgrid
    if @sessioned_user.address_line_1 && @sessioned_user.city && @sessioned_user.country
      url = URI("https://api.sendgrid.com/v3/marketing/senders")
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
      request["Content-Type"] = 'application/json'

      full_name = @sessioned_user.first_name + @sessioned_user.last_name
      data = { 
        "nickname": @sessioned_user.full_name,
        "from": { 
          "email": @sessioned_user.email,
          "name": @sessioned_user.full_name
        },
        "reply_to": {
          "email": @sessioned_user.email,
          "name": @sessioned_user.full_name
        },
        "address": @sessioned_user.address_line_1 || 'Bloomfield Ave',
        "address_2": @sessioned_user.address_line_2,
        "city": @sessioned_user.city || 'Windsor',
        "state": @sessioned_user.state || 'Connecticut',
        "zip": @sessioned_user.postal_code || '06095',
        "country": @sessioned_user.country || 'United States'
      }

      request.body = data.to_json
      response = http.request(request)
    end
  end

  protected

  # def self.default_url_options
  #   raise request.inspect
  #   { app: set_app }
  # end

  def current_app
    # @current_app ||= App.find_by_slug(params[:app]) || @sessioned_user&.app || App.find(session[:app_id])
    
    # x = Rails.cache.fetch([@sessioned_user&.app, "current_app"]) do
      # app = App.find_by_slug(params[:app]) || @sessioned_user&.app || App.find_by(name: "rockystepswaylive")
      app = App.find_by_slug(params[:app]) || @sessioned_user&.app || App.find_by(name: "eatndogoodlive")
      @old_app =  app unless app.nil?
      gon.current_app = app.slug
      app
    # end
    # puts x.slug
    # x
  end

  def require_logged_in
    if @sessioned_user.nil?
      flash[:danger] = t('flash.you_must_be_logged_in')
      redirect_to app_route(app_path(current_app))
    end
  end

  def set_admin_id
    @admin_id = params[:admin_id] if params[:admin_id].present?
    @admin_id = User.friendly.find(params[:user]).id if(@admin_id.nil? && !params[:user].nil? && params[:user].is_a?(String) )
    @admin_id =  @sessioned_user.id if(@admin_id.nil? && !@sessioned_user.nil? && @sessioned_user.admin?)

    if @admin_id.nil?
      @admin_id = @sessioned_user.chef_info.admin_id if !@sessioned_user.nil? && @sessioned_user.chef?
      @admin_id = @sessioned_user.guest_admin_user.id if (!@sessioned_user.nil? && @sessioned_user.guest? && @admin_id.nil?)
    end

    puts "admin id #{@admin_id}"
      
    @admin_id =  User.where(admin: true).first.id if @admin_id.nil?
  end

  def require_admin
    if !logged_in? || (logged_in? and !@sessioned_user.admin?)
      flash[:danger] = t('flash.only_admin_users_action')
      redirect_to app_route(app_ingredients_path(current_app))
    end
  end

  def require_admin_or_chef
    unless @sessioned_user.nil?
      unless (@sessioned_user.admin? || @sessioned_user.chef?)
        flash[:danger] = t('flash.only_admin_chef_action')
        redirect_to app_route(app_ingredients_path(current_app))
      end
    end
  end

  def after_sign_in_path_for(resource)
    cookies[:remember_rockystepsway_app_user_token] = cookies[:remember_app_user_token]
    cookies.delete(:remember_app_user_token)
    session[:chef_id] = params[:app].nil? ? current_user.chef_id : current_app_user.chef_id
    # if resource.guest
    #   @admin = resource.app.main_admin
    #   UserMailer.guest_create_email_to_admin(@admin.email, resource).deliver_now if @admin
    #   UserMailer.guest_create_email_to_guest(resource.email).deliver_now if @admin
    # end
    app_route(table_app_styles_path(current_app))
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    app = @old_app
    @old_app = nil

    @current_cart.destroy
    app_route(app_path(current_app))
  end

  # def add_params
  #   # raise params[:app_user].inspect
  #   app_id = current_app.id
  #   # params[:app_user].merge!(app_id: app_id) if (params[:app_user] && app_id)
  #   # raise params.inspect
  # end


  def configure_permitted_parameters
    # raise params.inspect
    # x = permit_attrs(%i[first_name last_name app_user])
    permit_attrs(%i[first_name last_name email address_line_1 address_line_2 city state postal_code country])
    devise_parameter_sanitizer.permit(:sign_in) do |user|
      user.permit(:email, :password, :remember_me, :app_id)
    end
    # raise self.class.permitted_params.inspect
    # raise params.inspect
    # added_attrs = [:app_user,:app]
    # devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
    
  end

  def check_app_user
    @sessioned_user = params[:app].nil? ? current_user : current_app_user
    # if @sessioned_user
    #   if @sessioned_user.app.parent_type == current_app.parent_type && @sessioned_user.app != current_app
    #     redirect_to(app_route(app_path(current_app, @sessioned_user.app)), notice: I18n.t('flash.you_must_log_out_from_app', current_app: @sessioned_user.app.slug, destination_app: current_app.slug))
    #   end
    # end
  end

  def permit_attrs(attrs)
    %i[sign_up account_update].each do |action|
      devise_parameter_sanitizer.permit(action, keys: attrs)
    end
  end

  def set_header_data
    @current_app = current_app
    # @ingredients = Ingredient.where(user_id: @admin_id)
    @all_ingredients = @current_app.ingredients
    # @allergens = Allergen.where(user_id: @admin_id)
    @all_allergens = @current_app.allergens
    # @styles = Style.where(user_id: @admin_id)
    @all_styles = @current_app.styles
  end

  def current_cart
    if @sessioned_user.present?
      cart = Cart.find_by(user_id: @sessioned_user.id)
      if cart
        @current_cart = cart
      else
        @current_cart = Cart.create(user_id: @sessioned_user.id, app_id: current_app.id)
      end
    end
  end

  def set_delivery_and_tax
    users = []
    @total_delivery = 0
    @total_tax = 0
    @current_cart.line_items.each do |line_item|
      if line_item.recipe && line_item.recipe.is_draft == false
        item_tax = line_item.quantity * line_item.recipe.price * (line_item.recipe.chef.user.product_tax/100)
        @total_tax += item_tax
        users << line_item.recipe.chef.user
      elsif line_item.gift_card
        gift_card_tax = line_item.quantity * 3.95
        @total_tax += gift_card_tax
        users << line_item.gift_card.user
      end
    end
    users.uniq.each { |user| @total_delivery += user.delivery_price }
  end

  def set_chef_ids
    users = current_app.users
    @chef_ids = users.includes(:chef_info).pluck("chefs.id")
  end

  def set_team_member
    if @sessioned_user&.chef_info
      if @sessioned_user.admin? || @sessioned_user.manager?
        @admin_id = @sessioned_user.chef_info&.id
      elsif @sessioned_user.chef?
        @staff_id = @sessioned_user.id
      end
    else
      redirect_to app_route(app_recipes_path(current_app))
    end
  end

  def check_admin
    return redirect_to app_route(app_recipes_path(current_app)) unless @admin_id
  end

  def set_selected_languages
    primary = []
    secondary = []

    languages_by_category = current_app.selected_languages.each_with_object({}) do |language, hash|
      hash[:primary] = primary << language[0..1] if language.include?('primary')
      hash[:secondary] = secondary << language[0..1] if language.include?('secondary')
    end

    @available_locales = LocaleDefinition::AVAILABLE_LOCALES.to_a.each do |locale|
      locale[0] += '_primary' if locale[0].in?(languages_by_category[:primary] || [])
      locale[0] += '_secondary' if locale[0].in?(languages_by_category[:secondary] || [])
    end
  end

  def set_devise_sender
    Devise.setup do |config|
      config.mailer_sender = current_app.main_admin.email
    end
  end

  def verify_app
    if params[:app].present?
      app = App.find_by(slug: params[:app])
      if app.nil?
        redirect_to app_route(root_path(current_app))
      end
    end
  end

  # Override devise method to handle User scope
  def bypass_sign_in(resource, scope: nil)
    # scope ||= Devise::Mapping.find_scope!(resource)
    scope ||= params[:app].nil? ? :user : :app_user
    expire_data_after_sign_in!
    warden.session_serializer.store(resource, scope)
  end
end

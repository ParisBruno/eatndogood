class ApplicationController < ActionController::Base
  include LocaleDefinition
  protect_from_forgery with: :exception
  helper_method :current_chef, :logged_in?, :current_app
  before_action :set_app, except: %i[send_emails destroy]
  before_action :check_app_user
  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :set_admin_id
  before_action :set_header_data
  before_action :current_cart

  def current_chef
    @current_chef ||= Chef.find(current_app_user.chef_info.id) if current_app_user && !current_app_user.chef_info.nil?
    raise @current_chef.inspect
  end

  def logged_in?
    current_app_user.chef? || current_app_user.admin?
  end

  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to app_path(current_app)
    end
  end

  def check_sendgrid_senders
    if current_app_user.admin?
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

        add_sender_to_sendgrid unless senders_emails.include?(current_app_user.email)
      end
    end
  end

  def add_sender_to_sendgrid
    if current_app_user.address_line_1 && current_app_user.city && current_app_user.country
      url = URI("https://api.sendgrid.com/v3/marketing/senders")
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
      request["Content-Type"] = 'application/json'

      full_name = current_app_user.first_name + current_app_user.last_name
      data = { 
        "nickname": current_app_user.full_name,
        "from": { 
          "email": current_app_user.email,
          "name": current_app_user.full_name
        },
        "reply_to": {
          "email": current_app_user.email,
          "name": current_app_user.full_name
        },
        "address": current_app_user.address_line_1 || 'Bloomfield Ave',
        "address_2": current_app_user.address_line_2,
        "city": current_app_user.city || 'Windsor',
        "state": current_app_user.state || 'Connecticut',
        "zip": current_app_user.postal_code || '06095',
        "country": current_app_user.country || 'United States'
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

  def set_app
    if controller_name != 'pictures'
      # raise current_app_user.inspect
      if params[:app].nil? || (current_app.parent_type != "rockystepsway" && params[:app] != "rockystepsway")
        redirect_to '/rockystepswaylive'
      else
        if params["action"] == "buy" && current_app_user.present?
          params[:app] = current_app_user.app.name
        end
        @app = current_app
        # @app.tap do
        #   session[:app_id] = @app.id if session[:app].nil?
        # end
      end
    end
  end

  def current_app
    # @current_app ||= App.find_by_slug(params[:app]) || current_app_user&.app || App.find(session[:app_id])
    
    # x = Rails.cache.fetch([current_app_user&.app, "current_app"]) do
      app = App.find_by_slug(params[:app]) || current_app_user&.app || App.find_by(name: "rockystepswaylive")
      @old_app =  app unless app.nil?
      gon.current_app = app.slug
      app
    # end
    # puts x.slug
    # x
  end

  def require_logged_in
    if current_app_user.nil?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to app_path(current_app)
    end
  end

  def set_admin_id
    @admin_id = params[:admin_id] if params[:admin_id].present?
    @admin_id = User.friendly.find(params[:user]).id if(@admin_id.nil? && !params[:user].nil? && params[:user].is_a?(String) )
    @admin_id =  current_app_user.id if(@admin_id.nil? && !current_app_user.nil? && current_app_user.admin?)

    if @admin_id.nil?
      @admin_id = current_app_user.chef_info.admin_id if !current_app_user.nil? && current_app_user.chef?
      @admin_id = current_app_user.guest_admin_user.id if (!current_app_user.nil? && current_app_user.guest? && @admin_id.nil?)
    end

    puts "admin id #{@admin_id}"
      
    @admin_id =  User.where(admin: true).first.id if @admin_id.nil?
  end

  def require_admin
    if !logged_in? || (logged_in? and !current_app_user.admin?)
      flash[:danger] = "Only admin users can perform that action"
      redirect_to ingredients_path
    end
  end

  def require_admin_or_chef
    unless current_app_user.nil?
      unless (current_app_user.admin? || current_app_user.chef?)
        flash[:danger] = "Only admin or chef users can perform that action"
        redirect_to app_ingredients_path(current_app)
      end
    end
  end

  def after_sign_in_path_for(resource)
    cookies[:remember_rockystepsway_app_user_token] = cookies[:remember_app_user_token]
    cookies.delete(:remember_app_user_token)
    session[:chef_id] = current_app_user.chef_id
    # if resource.guest
    #   @admin = resource.app.main_admin
    #   UserMailer.guest_create_email_to_admin(@admin.email, resource).deliver_now if @admin
    #   UserMailer.guest_create_email_to_guest(resource.email).deliver_now if @admin
    # end
    table_app_styles_path(current_app.slug)
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    app = @old_app
    @old_app = nil
    app_path(app)
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
    if current_app_user
      if current_app_user.app.parent_type == current_app.parent_type && current_app_user.app != current_app
        # redirect_to app_path(current_app_user.app), notice: "Please Logout from #{current_app_user.app.slug} before accessing #{current_app.slug}"
        redirect_to( app_path(current_app_user.app), notice: I18n.t('flash.you_must_log_out_from_app', current_app: current_app_user.app.slug, destination_app: current_app.slug))
      end
    end
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
    cart = Cart.find_by(id: session[:cart_id])
    if cart
      @current_cart = cart
    else
      session[:cart_id] = nil
      @current_cart = Cart.create
      session[:cart_id] = @current_cart.id
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
    @chef_ids = current_app.users.includes(:chef_info).pluck("chefs.id")
  end

  def set_team_member
    if current_app_user&.chef_info
      if current_app_user.admin? || current_app_user.manager?
        @admin_id = current_app_user.chef_info&.id
      elsif current_app_user.chef?
        @staff_id = current_app_user.id
      end
    else
      redirect_to app_recipes_path(current_app)
    end
  end

  def check_admin
    return redirect_to app_recipes_path(current_app) unless @admin_id
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
end

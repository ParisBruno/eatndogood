class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[paypal_create_payment paypal_execute_payment]
  before_action :set_delivery_and_tax, only: %i[new create]
  before_action :paypal_init, only: %i[paypal_create_payment paypal_execute_payment]
  before_action :set_order, only: %i[show update destroy]
  before_action :set_chef_ids
  before_action :set_credentials, only: %i[new create new_staff_order show]
  before_action :set_team_member, except: %i[new create paypal_create_payment paypal_execute_payment]
  # skip_before_action :set_app, :check_app_user, :set_header_data, only: %i[paypal_create_payment paypal_execute_payment]

  @@paypal_token ||= nil
  @@paypal_status ||= nil

  def index
    if params[:order_ids].present?
      @selected_orders = Order.where(id: params[:order_ids])
      @orders = Order.where(id: params[:orders])
    else
      if params[:search].present? && params[:search][:user_id].present?
        user_ids = [params[:search][:user_id]]
      else
        user_ids = params[:staff_ids].present? ? params[:staff_ids] : current_app.user_ids
      end
      if params[:search].present?
        orders = Order.where(user_id: user_ids)
        search_params = params[:search]
        orders = orders.where(status: search_params[:status]) if search_params[:status].present?
        orders = orders.where(is_home_delivery: search_params[:is_home_delivery]) if search_params[:is_home_delivery] && !search_params[:is_home_delivery].blank?
        orders = orders.where('created_at BETWEEN ? AND ?', search_params[:start_date], search_params[:end_date]) if search_params[:start_date].present? && search_params[:end_date].present?
        @orders = orders.order(name: :asc)
      else
        orders = Order.where(user_id: user_ids)
        @orders = orders.order(name: :asc)
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @@paypal_token = nil
    @@paypal_status = nil
    set_delivery_discount_tip(params[:delivery_price], params[:coupon_code], params[:coupon_amount_off].to_f, params[:coupon_percent_off].to_f,
                              params[:tip_value], params[:fundrasing_code])
    @order = Order.new
    @gift_card = GiftCard.where(client_email: @sessioned_user&.email, is_active: true, price: @total_amount..Float::INFINITY).last # !!!!!!client_email
  end

  def new_staff_order
    @order = Order.new
    @recipes = Recipe.where(chef_id: @chef_ids, is_draft: false).order(created_at: :desc)
  end

  def create
    set_delivery_discount_tip(order_params[:delivery_price], order_params[:coupon_code], order_params[:coupon_amount_off].to_f,
                              order_params[:coupon_percent_off].to_f, order_params[:tip_value], order_params[:fundrasing_code])
    @order = Order.new(order_params)

    unless @sessioned_user
      @guest = User.new(email: order_params[:email], first_name: order_params[:name], app_id: current_app.id,
                            password: order_params[:password], password_confirmation: order_params[:password_confirmation],
                            address_line_1: order_params[:address], phone: order_params[:phone])

      render 'new' and return unless @guest.save
    end

    @current_cart.line_items.each { |item| @order.line_items << item }

    set_orders_amounts(@order, current_app.admins.first&.id)
    @order.sub_total = (@current_cart.sub_total * 100).to_i
    @order.paypal_token = @@paypal_token
    @order.paypal_status = @@paypal_status
    @order.save!
        
    set_items_by_style(@order)
    email = @guest&.valid? ? @guest.email : @sessioned_user.email
    UserMailer.send_receipt_to_client(email, @order.id, @items_with_styles, current_app.main_admin&.email).deliver_now

    if params['cash'].present?
      create_cash_gift_paypal_order(@order, 'cash')
    elsif params['stripe'].present?
      create_stripe_order(@order, @current_cart, (@total_amount * 100).to_i)
    elsif params['gift_card'].present?
      create_cash_gift_paypal_order(@order, 'gift_card', order_params[:gift_card_id], @total_amount)
    else
      create_cash_gift_paypal_order(@order, 'paypal')
    end
  end

  def create_staff_order
    @order = Order.new(update_order_params)
    set_order_data(@order)

    delivery_price = if update_order_params[:delivery_price] == '1'
                      @total_delivery
                    else
                      0.0
                    end

    @order.is_home_delivery = if set_order_data(@order)[0].is_home_delivery
                                true
                              else
                                false
                              end
    
    coupon = CouponCode.find_by(title: update_order_params[:coupon_code], is_active: true)
    
    if update_order_params[:fundrasing_code].present?
      fundrasing = FundrasingCode.find_by(title: update_order_params[:fundrasing_code], is_active: true)
      @order.fundrasing_code = fundrasing&.title
    end

    set_delivery_discount_tip(delivery_price, coupon&.title, coupon&.coupon_amount_off.to_f, coupon&.coupon_percent_off.to_f,
                              update_order_params[:tip_value], update_order_params[:fundrasing_code], true)      
    set_orders_amounts(@order, @sessioned_user&.id)

    @order.sub_total = (@order.sub_total * 100).to_i
    @order.pay_method = 'cash'
    @order.save!

    set_items_by_style(@order)
    UserMailer.send_receipt_to_client(@order.email, @order.id, @items_with_styles).deliver_now if @order.email.present?
    redirect_to app_route(app_order_path(current_app, id: @order))
  end

  def show
    if @order && current_app.users.include?(@order.user)
      file_name = "order_#{@order.id}_#{@order.created_at&.strftime('%Y%m%d')}"
      @admin = current_app.main_admin
      respond_to do |format|
        format.html
        format.pdf do
          set_items_by_style(@order)
          send_data create_pdf, filename: "#{file_name}.pdf", type: 'application/pdf'
        end
      end
    else
      redirect_to app_route(app_orders_path(current_app)), notice: t('orders.not_defined')
    end
  end

  def update
    if @order.update(update_order_params)
      unless @order.line_items.present?
        @order.destroy

        redirect_to app_route(app_orders_path(current_app))
      else
        set_order_data(@order)
        set_delivery_discount_tip(@order.delivery_price, @order.coupon_code, @order.coupon_amount_off.to_f, @order.coupon_percent_off.to_f,
                                  @order.tip_value, update_order_params[:fundrasing_code], true)
        set_orders_amounts(@order, @sessioned_user&.id)
        @order.sub_total = (@order.sub_total * 100).to_i
        @order.status = 1 if update_order_params[:pay_method] == 'paypal'
        @order.save

        redirect_to app_route(app_order_path(current_app, id: @order))
      end
    else
      redirect_to app_route(app_order_path(current_app, id: @order)), alert: @order.errors.full_messages.join
    end
  end

  def return_stripe
    order = Order.last
    Stripe.api_key = @stripe_secret_key
    session = Stripe::Checkout::Session.list({limit: 1})
    payment = session.data.first

    order.stripe_session_id = payment.id
    order.stripe_status = payment.payment_status
    order.stripe_shipping = payment.shipping&.to_hash
    order.save!

    flash[:success] = I18n.t 'flash.client_create_order'
    redirect_to app_route(app_recipes_path(current_app))
  rescue Stripe::InvalidRequestError => e
    flash[:danger] = e.message
    redirect_to app_route(app_recipes_path(current_app))
  end

  def paypal_create_payment
    amount = order_params[:amount]

    unless @sessioned_user
      errors = []
      errors << "<li>email has already been taken</li>" if User.exists?(email: order_params[:email])
      errors << "<li>email is invalid</li>" unless order_params[:email] =~ URI::MailTo::EMAIL_REGEXP
      errors << "<li>password confirmation doesn't match password</li>" if order_params[:password] != order_params[:password_confirmation]
      
      if errors.present?
        render json: { error: errors.join('') }, status: :unprocessable_entity and return
      end
    end

    request = PayPalCheckoutSdk::Orders::OrdersCreateRequest::new
    request.request_body({
                          intent: "CAPTURE",
                          purchase_units: [
                            {
                              amount: {
                                currency_code: "USD",
                                value: amount
                              }
                            }
                          ]})
    response = @client.execute(request)

    @@paypal_token = response.result.id
    respond_to do |format|
      format.json { render json: { token: response.result.id }, status: :ok }
    end
  rescue PayPalHttp::HttpError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def paypal_execute_payment
    request = PayPalCheckoutSdk::Orders::OrdersCaptureRequest::new(params[:order_id])
    response = @client.execute(request)

    @@paypal_status = response.result.status
    respond_to do |format|
      format.json { render json: { data: response.result }, status: :ok }
    end
  rescue PayPalHttp::HttpError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def send_order_email
    OrderMailer.receipt_email(params[:order], current_app).deliver_now
    flash[:success] = t('orders.email_send_to_client')
    redirect_to app_route(app_order_path(current_app, id: params[:order]))
  end

  def destroy
    @order.destroy
    flash[:success] = I18n.t 'flash.order_removed'
    redirect_to app_route(app_orders_path(current_app))
  end

  private
  
  def set_order
    @order = Order.find_by(id: params[:id])
  end

  def create_cash_gift_paypal_order(order, pay_method, gift_card_id = nil, total_amount = nil)
    order.pay_method = pay_method
    order.save!

    @gift_card = GiftCard.find_by(id: gift_card_id)
    @gift_card&.reduce_price(total_amount)

    Cart.destroy(@current_cart.id)
    # session[:cart_id] = nil

    if order.line_items.where.not(gift_card_id: nil).present?
      order.line_items.pluck(:gift_card_id).compact.each do |gift_card_id|
        UserMailer.buy_gift_card_email(gift_card_id, current_app.id).deliver_now
      end
    end

    flash[:success] = I18n.t 'flash.client_create_order'
    respond_to do |format|
      format.js
    end
  end

  def create_stripe_order(order, current_cart, amount)
    amount = 50 if amount < 50

    product_name = []
    current_cart.line_items.each do |line_item|
      product_name << line_item.recipe.name + ' - ' + line_item.quantity.to_s + 'unit(s)'
    end
    coupon_id = if order_params[:coupon_code].present?
                  order_params[:coupon_code]
                else
                  []
                end

    stripe_session = create_session(amount, coupon_id, product_name.join(', '))
    if stripe_session[:session_id]
      order.pay_method = 'stripe'
      order.save!
      
      Cart.destroy(@current_cart.id)
      # session[:cart_id] = nil

      @session_id = stripe_session[:session_id]
      flash[:success] = I18n.t 'flash.client_create_order'
    end

    respond_to do |format|
      format.js
    end
  end

  def create_session(amount, coupon_id, product_name)
    Stripe.api_key = @stripe_secret_key
    @session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          unit_amount: amount,
          currency: 'usd',
          product_data: { name: product_name }
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: app_return_stripe_url,
      cancel_url: root_url,
    })

    { session_id: @session.id }
  rescue Stripe::InvalidRequestError => e
    { error: e.message }
  end

  def paypal_init
    set_paypal_credentials
    environment = PayPal::SandboxEnvironment.new(@paypal_client_id, @paypal_client_secret)
    @client = PayPal::PayPalHttpClient.new(environment)
  end

  def order_params
    params.require(:order).permit(:name, :email, :phone, :address, :coupon_code, :fundrasing_code, :amount, :delivery_price,
                                  :coupon_amount_off, :coupon_percent_off, :tip_value, :gift_card_id, :password, :password_confirmation, :is_home_delivery, :message)
  end

  def update_order_params
    params.require(:order).permit(:name, :email, :phone, :address, :pay_method, :status, :coupon_code, :fundrasing_code, :delivery_price, :tip_value,:message, :is_home_delivery, line_items_attributes: [:id, :quantity, :recipe_id, :note, :_destroy, recipe_attributes: [:id, :name]])
  end

  def set_delivery_discount_tip(delivery_price, coupon_code, coupon_amount_off, coupon_percent_off, tip_value, fundrasing_code, update_order = false)
    sub_total = if update_order
                   @order.sub_total
                else
                  @current_cart.sub_total
                end

    @delivery_price = delivery_price.to_f

    if !coupon_percent_off.zero?
      amount_coupon = false
      coupon_percent_off = CouponCode.find_by(title: coupon_code)&.coupon_percent_off if update_order
      coupon_amount = coupon_percent_off
    elsif !coupon_amount_off.zero?
      amount_coupon = true
      coupon_amount_off = CouponCode.find_by(title: coupon_code)&.coupon_amount_off if update_order
      coupon_amount = coupon_amount_off.to_f
    end

    @coupon_code = coupon_code
    @coupon_percent_off = coupon_amount
    @fundrasing_code = fundrasing_code
    @coupon_discount = if coupon_code.present?
                         amount_coupon ? coupon_amount * (-1) : (sub_total * (-1) * (coupon_amount.to_f/100))
                       else
                         0.0
                       end
    @tip_value = tip_value.to_f
    @total_amount = sub_total + @coupon_discount + @total_tax.to_f + @delivery_price.to_f + @tip_value.to_f
  end

  def set_orders_amounts(order, user_id)
    order.amount = (@total_amount * 100).to_i
    order.total_tax = @total_tax.to_f
    order.coupon_discount = @coupon_discount.to_f
    order.delivery_price = @delivery_price.to_f
    order.tip_value = @tip_value.to_f
    order.user_id = user_id
    order.save!
  end

  def set_order_data(order)
    users = []
    @total_delivery = 0
    @total_tax = 0
    order.line_items.each do |line_item|
      if line_item.recipe && line_item.recipe.is_draft == false
        item_tax = line_item.quantity * line_item.recipe.price.to_f * (line_item.recipe.chef.user.product_tax.to_f/100)
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

  def create_pdf
    WickedPdf.new.pdf_from_string(
      render_to_string('orders/show.pdf.erb', layout: 'pdf'),
      margin: {
        top: 0, bottom: '2.85cm', left: 0, right: 0
      }
    )
  end

  def set_paypal_credentials
    main_admin = current_app.main_admin
    @paypal_client_id = main_admin&.paypal_client_id
    @paypal_client_secret = main_admin&.paypal_client_secret
  end

  def set_items_by_style(order)
    styles_names = ['APPETIZERS', 'DESERT', 'DRINKS', 'GIFT CARD']

    order.line_items.where.not(recipe_id: nil).each do |line_item|
      style_name = line_item.recipe.styles&.first&.name
      styles_names.insert(1, style_name) unless styles_names.include?(style_name)
    end

    styles_data = styles_names.uniq.each_with_object(Hash.new(0)) { |style_name, hash| hash[style_name] = [] }
    
    order.line_items.each do |line_item|
      if line_item.recipe
        style_name = line_item.recipe.styles&.first&.name
        styles_data[style_name] << line_item
      else
        styles_data['GIFT CARD'] << line_item
      end
    end
    @items_with_styles = styles_data.reject { |key, value| value.empty? }
  end

  def set_credentials
    set_paypal_credentials
    main_admin = current_app.main_admin
    @stripe_publishable_key = main_admin&.stripe_publishable_key
    @stripe_secret_key = main_admin&.stripe_secret_key
  end
end

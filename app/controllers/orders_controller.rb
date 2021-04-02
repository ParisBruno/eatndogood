class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[paypal_create_payment paypal_execute_payment]
  before_action :set_delivery_and_tax, only: %i[new create]
  before_action :paypal_init, only: %i[paypal_create_payment paypal_execute_payment]
  before_action :set_chef_ids, :check_admin
  skip_before_action :set_app, :check_app_user, :set_header_data, only: %i[paypal_create_payment paypal_execute_payment]

  @@paypal_token ||= nil
  @@paypal_status ||= nil

  def index
    @orders = Order.joins(:line_items).joins(:recipes)
                   .where.not(line_items: { recipe_id: nil, order_id: nil })
                   .where(status: 0, line_items: { recipes: { chef_id: check_admin } })
                   .order(created_at: :desc)
  end

  def new
    @@paypal_token = nil
    @@paypal_status = nil
    set_delivery_discount_tip(params[:delivery_price], params[:coupon_code], 
                              params[:coupon_percent_off], params[:tip_value])
    @order = Order.new
    @gift_card = GiftCard.where(client_email: current_app_user.email, is_active: true, price: @total_amount..Float::INFINITY).last # !!!!!!client_email
  end

  def new_staff_order
    @order = Order.new
    @recipes = Recipe.where(chef_id: @chef_ids, is_draft: false).order(created_at: :desc)
  end

  def create
    set_delivery_discount_tip(order_params[:delivery_price], order_params[:coupon_code],
                              order_params[:coupon_percent_off], order_params[:tip_value])
    @order = Order.new(order_params)

    @current_cart.line_items.each { |item| @order.line_items << item }

    set_orders_amounts(@order)
    @order.sub_total = (@current_cart.sub_total * 100).to_i
    @order.paypal_token = @@paypal_token
    @order.paypal_status = @@paypal_status
    @order.save!

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
    
    coupon = CouponCode.find_by(title: update_order_params[:coupon_code], is_active: true)
    
    if update_order_params[:fundrasing_code].present?
      fundrasing = FundrasingCode.find_by(title: update_order_params[:fundrasing_code], is_active: true)
      @order.fundrasing_code = fundrasing&.title
    end

    set_delivery_discount_tip(delivery_price, coupon&.title, coupon&.coupon_percent_off,
                              update_order_params[:tip_value], true)      
    set_orders_amounts(@order)

    @order.sub_total = (@order.sub_total * 100).to_i
    @order.pay_method = 'cash'
    @order.save!

    redirect_to app_order_path(id: @order, app: current_app.slug)
  end

  def show
    @order = Order.find_by(id: params[:id])
    if @order.blank? || @order&.status == 'closed'
      redirect_to app_orders_path(current_app), notice: t('orders.not_defined')
    else
      recipe_ids = @order.line_items.pluck(:recipe_id)
      @recipes = Recipe.where(chef_id: @chef_ids, is_draft: false).where.not(id: recipe_ids).order(created_at: :desc)  
    end
  end

  def update
    @order = Order.find_by(id: params[:id])
    @order.update!(update_order_params)

    unless @order.line_items.present?
      @order.destroy

      redirect_to app_orders_path(current_app)
    else
      set_order_data(@order)
      set_delivery_discount_tip(@order.delivery_price, @order.coupon_code,
                                @order.coupon_percent_off, @order.tip_value, true)
      set_orders_amounts(@order)
      @order.sub_total = (@order.sub_total * 100).to_i
      @order.save!

      redirect_to app_order_path(id: @order, app: current_app.slug)
    end    
  end

  def return_stripe
    order = Order.last
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    session = Stripe::Checkout::Session.list({limit: 1})
    payment = session.data.first

    order.stripe_session_id = payment.id
    order.stripe_status = payment.payment_status
    order.stripe_shipping = payment.shipping.to_hash
    order.save!

    flash[:success] = I18n.t 'flash.success_stripe_payment'
    redirect_to app_recipes_path(current_app)
  rescue Stripe::InvalidRequestError => e
    flash[:danger] = e.message
    redirect_to app_recipes_path(current_app)
  end

  def paypal_create_payment
    amount = params[:amount]
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

  private

  def create_cash_gift_paypal_order(order, pay_method, gift_card_id = nil, total_amount = nil)
    order.pay_method = pay_method
    order.save!

    @gift_card = GiftCard.find_by(id: gift_card_id)
    @gift_card&.reduce_price(total_amount)

    Cart.destroy(session[:cart_id])
    session[:cart_id] = nil

    if order.line_items.where.not(gift_card_id: nil).present?
      order.line_items.pluck(:gift_card_id).compact.each do |gift_card_id|
        UserMailer.buy_gift_card_email(gift_card_id, current_app.id).deliver_later
      end
    end

    flash[:success] = I18n.t 'flash.success_stripe_payment'
    redirect_to app_recipes_path(current_app)
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
      
      Cart.destroy(session[:cart_id])
      session[:cart_id] = nil

      @session_id = stripe_session[:session_id]
      render 'create_checkout'
    else
      flash[:error] = stripe_session[:error]
      redirect_to new_app_order_path(current_app)
    end
  end

  def create_session(amount, coupon_id, product_name)
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    session = Stripe::Checkout::Session.create({
      customer_email: current_app_user.email,
      billing_address_collection: 'required',
      shipping_address_collection: {
        allowed_countries: ['US'],
      },
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          unit_amount: amount,
          currency: 'usd',
          product_data: { name: product_name }
        },
        quantity: 1,
      }],
      locale: I18n.locale,
      mode: 'payment',
      success_url: app_return_stripe_url(current_app),
      cancel_url: app_recipes_url(current_app),
    })

    { session_id: session.id }
  rescue Stripe::InvalidRequestError => e
    { error: e.message }
  end

  def paypal_init
    set_delivery_and_tax
    environment = PayPal::SandboxEnvironment.new(@paypal_client_id, @paypal_client_secret)
    @client = PayPal::PayPalHttpClient.new(environment)
  end

  def order_params
    params.require(:order).permit(:name, :email, :phone, :address, :coupon_code, :fundrasing_code,
                                  :delivery_price, :coupon_percent_off, :tip_value, :gift_card_id)
  end

  def update_order_params
    params.require(:order).permit(:name, :email, :phone, :address, :status, :coupon_code, :fundrasing_code, :delivery_price, :tip_value,
                                  line_items_attributes: [:id, :quantity, :recipe_id, :_destroy, recipe_attributes: [:id, :name]])
  end

  def set_delivery_discount_tip(delivery_price, coupon_code, coupon_percent_off, tip_value, update_order = false)
    sub_total = if update_order
                   @order.sub_total
                else
                  @current_cart.sub_total
                end

    @delivery_price = delivery_price.to_f
    coupon_percent_off = CouponCode.find_by(title: coupon_code)&.coupon_percent_off if update_order
    @coupon_discount = if coupon_code.present?
                        sub_total * (-1) * (coupon_percent_off.to_f/100)
                       else
                        0.0
                       end
    @tip_value = tip_value.to_f
    @total_amount = sub_total + @coupon_discount + @total_tax.to_f + @delivery_price
  end

  def set_orders_amounts(order)
    order.amount = (@total_amount * 100).to_i
    order.total_tax = @total_tax.to_f
    order.coupon_discount = @coupon_discount.to_f
    order.delivery_price = @delivery_price.to_f
    order.tip_value = @tip_value.to_f
    order.save!
  end

  def set_order_data(order)
    users = []
    @total_delivery = 0
    @total_tax = 0
    order.line_items.each do |line_item|
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
end

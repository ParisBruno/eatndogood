class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[paypal_create_payment paypal_execute_payment]
  before_action :set_delivery_and_tax, only: %i[new create]
  before_action :paypal_init, only: %i[paypal_create_payment paypal_execute_payment]
  skip_before_action :set_app, :check_app_user, :set_header_data, only: %i[paypal_create_payment paypal_execute_payment]

  @@paypal_token ||= nil
  @@paypal_status ||= nil

  def index
    @orders = Order.all
  end

  def new
    @@paypal_token = nil
    @@paypal_status = nil
    set_delivery_discount_tip(params[:delivery_price], params[:coupon_code], 
                              params[:coupon_percent_off], params[:tip_value])
    @order = Order.new
  end

  def create
    set_delivery_discount_tip(order_params[:delivery_price], order_params[:coupon_code],
                              order_params[:coupon_percent_off], order_params[:tip_value])
    @order = Order.new(order_params)
    amount = (@total_amount * 100).to_i

    @current_cart.line_items.each { |item| @order.line_items << item }
    @order.amount = amount
    @order.paypal_token = @@paypal_token
    @order.paypal_status = @@paypal_status

    if params['cash'].present?
      create_cash_or_paypal_order(@order, 'cash')
    elsif params['stripe'].present?
      create_stripe_order(@order, @current_cart, amount)
    else
      create_cash_or_paypal_order(@order, 'paypal')
    end
  end

  def show
    @order = Order.find(params[:id])
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

  def create_cash_or_paypal_order(order, pay_method)
    order.pay_method = pay_method
    order.save!

    Cart.destroy(session[:cart_id])
    session[:cart_id] = nil

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

  def order_params
    params.require(:order).permit(:name, :email, :phone, :address, :coupon_code,
                                  :delivery_price, :coupon_percent_off, :tip_value)
  end

  def set_delivery_discount_tip(delivery_price, coupon_code, coupon_percent_off, tip_value)
    @delivery_price = delivery_price.to_f
    @coupon_discount = if coupon_code.present?
                        @current_cart.sub_total * (-1) * (coupon_percent_off.to_f/100)
                       else
                        0.0
                       end
    @tip_value = tip_value.to_f
    @total_amount = @current_cart.sub_total + @coupon_discount + @total_tax.to_f + @delivery_price + @tip_value.to_f
  end

  def paypal_init
    set_delivery_and_tax
    environment = PayPal::SandboxEnvironment.new(@paypal_client_id, @paypal_client_secret)
    @client = PayPal::PayPalHttpClient.new(environment)
  end
end

class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[paypal_create_payment paypal_execute_payment]
  before_action :set_delivery_and_tax, only: %i[new create]
  before_action :paypal_init, only: %i[paypal_create_payment paypal_execute_payment]
  skip_before_action :set_app, :check_app_user, :set_header_data, only: %i[paypal_create_payment paypal_execute_payment]

  def index
    @orders = Order.all
  end

  def new
    set_delivery_discount_tip(params[:delivery_price], params[:coupon_code], params[:coupon_percent_off], params[:tip_value])
    @order = Order.new
  end

  def create
    set_delivery_discount_tip(order_params[:delivery_price], order_params[:coupon_code], order_params[:coupon_percent_off], order_params[:tip_value])
    @order = Order.new(order_params)
    amount = (@total_amount * 100).to_i

    if params['cash'].present?
      create_cash_order(@order, @current_cart, amount)
    elsif params['stripe'].present?
      create_stripe_order(@order, @current_cart, amount)
    else
      create_paypal_order(@order, @current_cart, amount)
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def return_stripe
    order = Order.last
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    payment = Stripe::PaymentIntent.list({limit: 1}) # "status": "succeeded" "requires_payment_method"
    session = Stripe::Checkout::Session.list({limit: 1}) # "payment_status": "paid" # paid, unpaid, no_payment_required

    # {
    #   "id": "cs_test_a1c2ZRPwp5afDfAGBxbZJH0BAB5UiHGmKvg6aMX2dDkR2PKCGY72fyIyCr",
    #   "amount_subtotal": 2200,
    #   "amount_total": 2200,
    #   "currency": "usd",
    #   "payment_intent": "pi_1HntmLJhzcOxD4pHsNKJf4t4",
    #   "payment_method_types": [
    #     "card"
    #   ],
    #   "payment_status": "paid",
    #   "shipping": {"address":{"city":"Kremenchuck","country":"US","line1":"Molodizhna street , 1/2, app.26","line2":null,"postal_code":"39622","state":"MN"},"name":"ggg"},
    #   "total_details": {"amount_discount":0,"amount_tax":0}
    # }

    # {
    #   "id": "pi_1HntmLJhzcOxD4pHsNKJf4t4",
    #   "object": "payment_intent",
    #   "amount": 2200,
    #   "amount_received": 2200,
    #   "created": 1605479581,
    #   "currency": "usd",
    #   "payment_method": "pm_1HntmuJhzcOxD4pHzlO3FuSr",
    #   "shipping": {"address":{"city":"Kremenchuck","country":"US","line1":"Molodizhna street , 1/2, app.26","line2":null,"postal_code":"39622","state":"MN"},"carrier":null,"name":"ggg","phone":null,"tracking_number":null},
    #   "status": "succeeded",
    # }
    p session.data.first #.payment_status
    p payment.data.first #.status
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
                            ]
                          })

    response = @client.execute(request)
    # order = Order.new
    # order.price = price.to_i
    # order.token = response.result.id
    # if order.save
    respond_to do |format|
      format.json { render json: { token: response.result.id }, status: :ok }
    end
    # order = response.result
    # puts order
  rescue PayPalHttp::HttpError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: e.http_status }
    end
  end

  def paypal_execute_payment
    request = PayPalCheckoutSdk::Orders::OrdersCaptureRequest::new(params[:order_id])

    # Call API with your client and get a response for your call
    response = @client.execute(request) 
    
    # If call returns body in response, you can get the deserialized version from the result attribute of the response
    # order = Order.find_by :token => params[:order_id]
    #   order.paid = response.result.status == 'COMPLETED'
    #   if order.save
    #     return render :json => {:status => response.result.status}, :status => :ok
    #   end
    # order = response.result
    # puts order

    respond_to do |format|
      format.json { render json: { data: response.result }, status: :ok }
    end
  rescue PayPalHttp::HttpError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: e.http_status }
    end
  end

  private

  def create_cash_order(order, current_cart, amount)
    # amount = amount

    current_cart.line_items.each do |item|
      order.line_items << item
      order.pay_method = 'cash'
    end
    order.save!

    Cart.destroy(session[:cart_id])
    session[:cart_id] = nil

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
      current_cart.line_items.each do |item|
        order.line_items << item
        order.pay_method = 'stripe'
      end
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

  def create_paypal_order(order, current_cart, amount)
    # amount = amount

    current_cart.line_items.each do |item|
      order.line_items << item
      order.pay_method = 'paypal'
    end
    order.save!

    Cart.destroy(session[:cart_id])
    session[:cart_id] = nil

    redirect_to app_recipes_path(current_app)
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
      success_url: app_recipes_url(current_app),
      cancel_url: app_recipes_url(current_app),
    })

    { session_id: session.id }
  rescue Stripe::InvalidRequestError => e
    { error: e.message }
  end

  def order_params
    params.require(:order).permit(:name, :email, :phone, :address, :coupon_code, :delivery_price, :coupon_percent_off, :tip_value)
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
    client_id = ENV['TEST_PAYPAL_CLIENT_ID']
    client_secret = ENV['TEST_PAYPAL_CLIENT_SECRET']
    environment = PayPal::SandboxEnvironment.new(client_id, client_secret)
    @client = PayPal::PayPalHttpClient.new(environment)
  end
end

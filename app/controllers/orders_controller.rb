class OrdersController < ApplicationController

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    amount = @current_cart.sub_total.to_i * 100
    amount = 50 if amount < 50

    product_name = []
    @current_cart.line_items.each do |line_item|
      product_name << line_item.recipe.name + ' - ' + line_item.quantity.to_s + 'unit(s)'
    end

    if order_params[:coupon_code].present?
      coupon_id = order_params[:coupon_code]
    else
      coupon_id = []
    end

    stripe_session = create_session(amount, coupon_id, product_name.join(', '))
    if stripe_session[:session_id]
      @current_cart.line_items.each do |item|
        @order.line_items << item
        @order.pay_method = 'card'
      end
      @order.save
      
      Cart.destroy(session[:cart_id])
      session[:cart_id] = nil

      @session_id = stripe_session[:session_id]
      render 'create_checkout'
    else
      flash[:error] = stripe_session[:error]
      redirect_to new_app_order_path(current_app)
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def create_session(amount, coupon_id, product_name)
    Stripe.api_key = ENV['TEST_STRIPE_SECRET_KEY']

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
      discounts: [{
        coupon: coupon_id,
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
    params.require(:order).permit(:name, :email, :phone, :address, :coupon_code)
  end
end

class OrdersController < ApplicationController
  before_action :set_delivery_and_tax, only: %i[new create]

  def index
    @orders = Order.all
  end

  def new
    set_delivery_and_discount(params[:delivery_price], params[:coupon_code], params[:coupon_percent_off])
    
    @order = Order.new
  end

  def create
    set_delivery_and_discount(order_params[:delivery_price], order_params[:coupon_code], order_params[:coupon_percent_off])

    @order = Order.new(order_params)
    amount = ((@current_cart.sub_total + @coupon_discount + @total_tax.to_f + @delivery_price) * 100).to_i
    amount = 50 if amount < 50

    product_name = []
    @current_cart.line_items.each do |line_item|
      product_name << line_item.recipe.name + ' - ' + line_item.quantity.to_s + 'unit(s)'
    end

    coupon_id = if order_params[:coupon_code].present?
                  order_params[:coupon_code]
                else
                  []
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
    params.require(:order).permit(:name, :email, :phone, :address, :coupon_code, :delivery_price, :coupon_percent_off)
  end

  def set_delivery_and_discount(delivery_price, coupon_code, coupon_percent_off)
    @delivery_price = delivery_price.to_f
    @coupon_discount = if coupon_code.present?
                        @current_cart.sub_total * (-1) * (coupon_percent_off.to_f/100)
                       else
                        0.0
                       end
  end
end

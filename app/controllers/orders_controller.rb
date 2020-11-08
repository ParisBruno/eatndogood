class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_app, only: %i[create create_session cancel success] #, :check_app_user, :set_header_data

  def index
    @orders = Order.all
    Stripe.api_key = 'sk_test_51Hkyh8JhzcOxD4pHctIVpnzk6HI9jwVUpjjNaecTaVyDFk0dXnx56PEKr82T5AxXocLLb1Etd1PuTl2UlfwLd1KZ00tHQmC9IT'

account = Stripe::Account.create({
  type: 'express',
})
  end

  def create
    @order = Order.new(order_params)
    @current_cart.line_items.each do |item|
      @order.line_items << item
      # item.cart_id = nil
    end

    Stripe.api_key = 'sk_test_51Hkyh8JhzcOxD4pHctIVpnzk6HI9jwVUpjjNaecTaVyDFk0dXnx56PEKr82T5AxXocLLb1Etd1PuTl2UlfwLd1KZ00tHQmC9IT'

    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'T-shirt',
          },
          unit_amount: 2000,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: "https://yoursite.com/success.html",
      cancel_url: 'https://example.com/cancel',
    })
    p session
    # `source` is obtained with Stripe.js; see https://stripe.com/docs/payments/accept-a-payment-charges#web-create-token
    charge = Stripe::Charge.create({
      amount: 2000,
      currency: 'usd',
      source: 'tok_amex',
      description: 'My First Test Charge (created for API docs)',
    })

    p charge


    # byebug
    redirect_to new_app_order_path(current_app)


    # @order.save
    # Cart.destroy(session[:cart_id])
    # session[:cart_id] = nil
    # redirect_to root_path
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create_session
    Stripe.api_key = 'sk_test_51Hkyh8JhzcOxD4pHctIVpnzk6HI9jwVUpjjNaecTaVyDFk0dXnx56PEKr82T5AxXocLLb1Etd1PuTl2UlfwLd1KZ00tHQmC9IT'

    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          unit_amount: 2000,
          currency: 'usd',
          product_data: {
            name: 'Stubborn Attachments',
            images: ['https://i.imgur.com/EHyR2nP.png'],
          },
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: 'http://localhost:3000/success.html',
      cancel_url: 'http://localhost:3000/cancel.html',
    })

    {
      id: session.id
    }.to_json
  end

  def success
    render 'success'
  end

  def cancel
    render 'cancel'
  end

  private
  
  def order_params
    params.require(:order).permit(:name, :email, :phone, :address, :pay_method)
  end
end

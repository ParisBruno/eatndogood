class CartsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[check_coupon add_coupon check_delivery]
  skip_before_action :set_app, :check_app_user, :set_header_data, only: %i[add_coupon check_coupon check_delivery]
  
  @@coupon_id ||= []
  @@delivery_price ||= 0

  def show
    set_delivery_and_tax
    @current_cart
    @@coupon_id = []
    @@delivery_price = 0
  end

  def add_coupon
    redirect_to new_app_order_path(current_app, params: { coupon_code: @@coupon_id, delivery_price: @@delivery_price })
  end

  def check_delivery
    if params[:delivery_price] == 'true'
      set_delivery_and_tax
      @@delivery_price = @total_delivery
    else
      @@delivery_price = 0
    end
    respond_to do |format|
      format.json { render json: { data: @@delivery_price.to_f }, status: :ok }
      format.js
    end

  rescue StandardError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: e.http_status }
    end
  end

  def check_coupon
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    
    @@coupon_id = []
    if params[:coupon_code].present?
      coupon_code = params[:coupon_code]
    else
      coupon_code = ' '
    end
    coupon = Stripe::Coupon.retrieve(coupon_code)
    @@coupon_id = coupon.id if coupon.id.present?

    respond_to do |format|
      format.json { render json: { data: coupon.id }, status: :ok }
    end
  rescue Stripe::InvalidRequestError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: e.http_status }
    end
  end

  def destroy
    @current_cart
    @current_cart.destroy
    session[:cart_id] = nil

    redirect_to app_recipes_path(current_app)
  end
end

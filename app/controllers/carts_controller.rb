class CartsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[check_coupon add_coupon check_delivery]
  skip_before_action :set_app, :check_app_user, :set_header_data, except: %i[show destroy]
  
  @@coupon_id ||= []
  @@delivery_price ||= 0
  @@delivery_value ||= false

  def show
    set_delivery_and_tax
    @@delivery_value = false
    @delivery_check_value = @@delivery_value
    @current_cart
    @@coupon_id = []
    @@delivery_price = 0
  end

  def add_coupon
    redirect_to new_app_order_path(current_app, params: { coupon_code: @@coupon_id, delivery_price: @@delivery_price })
  end

  def check_delivery
    if params['check-delivery'] == 'false'
      @@delivery_value = true
      @delivery_check_value = true
      set_delivery_and_tax
      @@delivery_price = @total_delivery
    else
      @@delivery_value = false
      @delivery_check_value = false
      set_delivery_and_tax
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

  def destroy_item
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    respond_to do |format|
      set_delivery_and_tax
      @delivery_check_value = @@delivery_value
      format.html { redirect_to app_cart_path(current_app, @current_cart) }
      format.js
    end
  end

  def add_quantity
    @line_item = LineItem.find(params[:id])
    @line_item.quantity += 1

    respond_to do |format|
      if @line_item.save
        set_delivery_and_tax
        @delivery_check_value = @@delivery_value
        format.html { redirect_to app_cart_path(current_app, @current_cart) }
        format.js
      else
        format.html { render action: 'new' and return }
      end
    end
  end
  
  def reduce_quantity
    @line_item = LineItem.find(params[:id])
    if @line_item.quantity > 1
      @line_item.quantity -= 1
    end

    respond_to do |format|
      if @line_item.save
        set_delivery_and_tax
        @delivery_check_value = @@delivery_value
        format.html { redirect_to app_cart_path(current_app, @current_cart) }
        format.js
      else
        format.html { render action: 'new' and return }
      end
    end
  end

  def destroy
    @current_cart
    @current_cart.destroy
    session[:cart_id] = nil

    redirect_to app_recipes_path(current_app)
  end
end

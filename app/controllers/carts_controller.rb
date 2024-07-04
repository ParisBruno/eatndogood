class CartsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[check_stripe_coupon check_coupon check_fundrasing add_additional_params check_delivery check_tip]
  # skip_before_action :set_app, :check_app_user, :set_header_data, except: %i[show destroy]
  
  @@coupon_id ||= []
  @@coupon_percent_off ||= []
  @@coupon_amount_off ||= []
  @@delivery_price ||= 0
  @@delivery_value ||= false
  @@coupon_value ||= nil
  @@fundrasing_value ||= nil
  @@tip_value ||= 0

  def show
    set_delivery_and_tax
    @@delivery_value = false
    @@coupon_id = []
    @@coupon_percent_off = []
    @@coupon_amount_off = []
    @@delivery_price = 0
    @@tip_value = 0
    @@coupon_value = nil
    @@fundrasing_value = nil

    @coupon_code_value = @@coupon_value
    @fundrasing_code_value = @@fundrasing_value
    @delivery_check_value = @@delivery_value
    @tip = @@tip_value

    @current_cart
  end

  def add_additional_params
    redirect_to app_route(new_app_order_path(current_app, params: { coupon_code: @@coupon_id,
                                                          coupon_percent_off: @@coupon_percent_off,
                                                          coupon_amount_off: @@coupon_amount_off,
                                                          fundrasing_code: @@fundrasing_value,
                                                          delivery_price: @@delivery_price,
                                                          tip_value: @@tip_value,
                                                          home_delivery: @@delivery_value
                                                        }))
  end

  def check_delivery
    if params['check-delivery'] == 'true'
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
    @coupon_code_value = @@coupon_value
    @fundrasing_code_value = @@fundrasing_value
    @tip = @@tip_value

    respond_to do |format|
      format.json { render json: { data: @@delivery_price.to_f }, status: :ok }
      format.js
    end

  rescue StandardError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def check_tip
    set_delivery_and_tax
    if params[:tip].present?
      @@tip_value = params[:tip]
      @tip = params[:tip]
      @delivery_check_value = @@delivery_value
    end
    @coupon_code_value = @@coupon_value
    @fundrasing_code_value = @@fundrasing_value

    respond_to do |format|
      format.js
    end

  rescue StandardError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def check_stripe_coupon
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    
    @@coupon_id = []
    coupon_code = if params[:coupon_code].present?
                    params[:coupon_code]
                  else
                    ' '
                  end
    coupon = Stripe::Coupon.retrieve(coupon_code)
    @@coupon_id = coupon.id if coupon.id.present?
    @@coupon_percent_off = coupon.percent_off if coupon.percent_off.present?
    @delivery_check_value = @@delivery_value
    @tip = @@tip_value

    respond_to do |format|
      @@coupon_value = params[:coupon_code]
      @coupon_code_value = params[:coupon_code]
      format.json { render json: { data: coupon.id }, status: :ok }
    end
  rescue Stripe::InvalidRequestError => e
    respond_to do |format|
      @@coupon_value = nil
      @coupon_code_value = nil
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def check_coupon
    coupon = CouponCode.find_by(title: params[:coupon_code], is_active: true)
    @delivery_check_value = @@delivery_value
    @tip = @@tip_value
    @fundrasing_code_value = @@fundrasing_value

    if coupon
      @@coupon_id = coupon.title
      @@coupon_percent_off = coupon.coupon_percent_off
      @@coupon_amount_off = coupon.coupon_amount_off
      @@coupon_value = params[:coupon_code]
      @coupon_code_value = params[:coupon_code]

      respond_to do |format|
        format.json { render json: { data: coupon.title }, status: :ok }
      end
    else
      respond_to do |format|
        @@coupon_value = nil
        @coupon_code_value = nil
        format.json { render json: { error: t('common.no_such_coupan', coupan_code: params[:coupon_code]) }, status: :unprocessable_entity }
      end
    end
  end

  def check_fundrasing
    coupon = FundrasingCode.find_by(title: params[:coupon_code], is_active: true)
    @delivery_check_value = @@delivery_value
    @coupon_code_value = @@coupon_value

    if coupon
      @@fundrasing_value = params[:coupon_code]
      @fundrasing_code_value = params[:coupon_code]

      respond_to do |format|
        format.json { render json: { data: coupon.title }, status: :ok }
      end
    else
      respond_to do |format|
        @@fundrasing_value = nil
        @fundrasing_code_value = nil
        format.json { render json: { error: t('common.no_such_coupan', coupan_code: params[:coupon_code]) }, status: :unprocessable_entity }
      end
    end
  end

  def destroy_item
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    set_delivery_and_tax
    @delivery_check_value = @@delivery_value
    @coupon_code_value = @@coupon_value
    @fundrasing_code_value = @@fundrasing_value
    @tip = @@tip_value

    respond_to do |format|
      format.html { redirect_to app_route(app_cart_path(current_app, @current_cart)) }
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
        @coupon_code_value = @@coupon_value
        @fundrasing_code_value = @@fundrasing_value
        @tip = @@tip_value
        format.html { redirect_to app_route(app_cart_path(current_app, @current_cart)) }
        format.js
      else
        format.js
        format.html { render action: 'show' and return }
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
        @coupon_code_value = @@coupon_value
        @fundrasing_code_value = @@fundrasing_value
        @tip = @@tip_value
        format.html { redirect_to app_route(app_cart_path(current_app, @current_cart)) }
        format.js
      else
        format.html { render action: 'show' and return }
      end
    end
  end

  def destroy
    @current_cart
    @current_cart.destroy
    session[:cart_id] = nil

    redirect_to app_route(app_recipes_path(current_app))
  end
end

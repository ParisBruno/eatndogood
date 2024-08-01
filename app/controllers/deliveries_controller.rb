class DeliveriesController < ApplicationController
  require 'google_maps_service'
  before_action :require_staff_and_admin
  before_action :set_team_members, only: [:index, :new, :create, :edit, :update]
  before_action :set_orders, only: [:new, :create, :edit, :update]
  before_action :set_delivery, only: [:edit, :update, :destroy]

  def index
    @deliveries = if @sessioned_user.admin?
                    current_app.deliveries
                  elsif @sessioned_user.manager?
                    @sessioned_user.deliveries
                  else
                    Delivery.where('user_id = ? AND status != ?', @sessioned_user.id, 0)
                  end
    @deliveries = @deliveries.where(status: params[:status]) if params[:status].present?

    # Arrange deliveries
    @deliveries = arrange_deliveries(@deliveries) if params[:current_location].present?

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @delivery = Delivery.new
  end

  def create
    @delivery = Delivery.new(delivery_params)
    if @delivery.save
      redirect_to app_route(app_deliveries_path(current_app))
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @delivery.update(delivery_params)
      redirect_to app_route(app_deliveries_path(current_app))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @delivery.destroy
    redirect_to app_route(app_deliveries_path(current_app))
  end

  def assign_driver
    selected_delivery_ids = JSON.parse(params[:selected_delivery_ids])
    user_id = params[:user_id]

    if selected_delivery_ids.present? && user_id.present?
      deliveries = Delivery.where(id: selected_delivery_ids)
      deliveries.update_all(user_id: user_id, status: 'assigned')
      DeliveryMailer.send_driver_email(selected_delivery_ids).deliver_now
    end

    @deliveries = if @sessioned_user.admin?
                    current_app.deliveries
                  elsif @sessioned_user.manager?
                    @sessioned_user.deliveries
                  else
                    Delivery.where('user_id = ? AND status != ?', @sessioned_user.id, 0)
                  end

    respond_to do |format|
      format.js { render 'index' }
    end
  end

  private
  def delivery_params
    params.require(:delivery).permit(:location, :user_id, :status, :note, :image, :app_id, :order_id, :created_by_user_id)
  end

  def set_team_members
    @team_members = current_app.users.where(admin: nil, manager: false, chef: true)
  end

  def require_staff_and_admin
    if @sessioned_user.nil? || !@sessioned_user&.chef?
      redirect_to app_route(root_path(current_app))
    end
  end

  def set_delivery
    @delivery = Delivery.find(params[:id])
  end

  def set_orders
    @order = Order.find(params[:order_id]) if params[:order_id].present?
    user_ids = @sessioned_user.manager? ? [@sessioned_user.id] + @sessioned_user.staff_ids : current_app.user_ids
    @orders = Order.left_outer_joins(:delivery).where(user_id: user_ids, is_home_delivery: true, deliveries: { id: nil }).order(name: :asc)
  end

  def arrange_deliveries(deliveries)
    assigned_deliveries = deliveries.where(status: 1)
    other_deliveries = deliveries - assigned_deliveries

    start_location = params[:current_location]
    start_coords = $gmaps.geocode(start_location).first[:geometry][:location]

    geocoded_locations = assigned_deliveries.map do |delivery|
      geocode_location = $gmaps.geocode(delivery.location)
      coords = geocode_location.present? ? $gmaps.geocode(delivery.location).first[:geometry][:location] : 0
      { delivery: delivery, address: delivery.location, coords: coords }
    end

    distances = geocoded_locations.map do |location|
      distance = location[:coords] != 0 ? haversine_distance(start_coords, location[:coords]).round(0) : ""
      { delivery: location[:delivery], address: location[:address], distance: distance }
    end

    sorted_deliveries = distances.sort_by do |location|
      location[:distance].to_s.empty? ? Float::INFINITY : location[:distance].to_f
    end

    sorted_deliveries + other_deliveries
  end

  def haversine_distance(coord1, coord2)
    rad_per_deg = Math::PI / 180
    rkm = 6371 # Earth radius in kilometers
    rm = rkm * 1000 # Radius in meters

    dlat_rad = (coord2[:lat] - coord1[:lat]) * rad_per_deg
    dlon_rad = (coord2[:lng] - coord1[:lng]) * rad_per_deg

    lat1_rad, lon1_rad = coord1.values.map { |i| i * rad_per_deg }
    lat2_rad, lon2_rad = coord2.values.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

    rm * c # Delta in meters
  end
end

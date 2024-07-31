class DeliveriesController < ApplicationController
  before_action :require_staff_and_admin
  before_action :set_team_members, only: [:index, :new, :create, :edit, :update]
  before_action :set_delivery, only: [:edit, :update, :destroy]

  def index
    @deliveries = if @sessioned_user.admin?
                    current_app.deliveries
                  else
                    Delivery.where('user_id = ? AND status != ?', @sessioned_user.id, 0)
                  end
    @deliveries = @deliveries.where(status: params[:status]) if params[:status].present?

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @delivery = Delivery.new
    results = $gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')
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

    respond_to do |format|
      format.js
    end
  end

  private
  def delivery_params
    params.require(:delivery).permit(:location, :user_id, :status, :note, :image, :app_id)
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
end

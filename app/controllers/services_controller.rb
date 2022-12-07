class ServicesController < ApplicationController
  before_action :set_service, only: [:update, :destroy, :show]

  def index
    @service_types = current_app.service_types
    @service_type = params[:service_types].present? ? @service_types.find(params[:service_types]) : @service_types.first
  end

  def slots
    service_type = ServiceType.find(params[:service_type])
    @avail_slots = service_type.available_time_slots(params[:service_day], params[:people])
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def schedule_services
    @services = current_app.services
  end

  def services_listing
    @services = current_app.services.where.not(start_day: nil)
  end

  def create
    params[:service][:icon] = params[:service][:icon].split('>').last+">"
    @service = Service.new(service_params)
    @service.save
    @services = current_app.services
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def show
    @service_slots = @service.service_slots
    @service_slots = @service_slots.where('day BETWEEN ? AND ?', params[:start_time].to_date.beginning_of_day, params[:end_time].to_date.end_of_day) if params[:start_time].present?
    @service_slots = @service_slots.where(first_name: params[:first_name]) if params[:first_name].present?
    @service_slots = @service_slots.where(last_name: params[:last_name]) if params[:last_name].present?
  end

  def update
    params[:service] = params[:service].except(:icon) if params[:service][:icon] == ""
    @service.update(service_params)
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def destroy
    @service.destroy
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  private
  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name, :customers, :start_day, :end_day, :start_time, :end_time, :user_id, :app_id, :service_type_id, :icon)
  end
end

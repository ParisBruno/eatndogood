class ServiceSlotsController < ApplicationController
  before_action :set_service_slot, only: [:update, :destroy]

  def create
    @slot = ServiceSlot.new(service_slot_params)
    if @slot.save!
      flash[:success] = t('services.booked_successfully')
      ServiceMailer.send_booking_confirmation(current_app, @slot).deliver_now if @slot.email.present?
      ServiceMailer.send_booking_admin_confirmation(current_app, current_app_user, @slot).deliver_now
      redirect_to app_services_path(current_app)
    end
  end

  def update
    if @service_slot.update(service_slot_params)
      flash[:success] = t('common.successfully_updated', name: 'ServiceSlot')
      redirect_to app_service_path(current_app, @service_slot.service_id)
    else
      render 'edit'
    end
  end

  def destroy
    @service_slot.destroy
    redirect_to app_service_path(current_app, @service_slot.service_id)
  end

  private
  def set_service_slot
    @service_slot = ServiceSlot.find(params[:id])
  end

  def service_slot_params
    params.require(:service_slot).permit(:first_name, :last_name, :number_of_people, :day, :start_time, :end_time, :service_id, :email, :phone_number, :booked, :address)
  end
end

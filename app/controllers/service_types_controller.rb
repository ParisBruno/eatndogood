class ServiceTypesController < ApplicationController

  def create
    @service_type = ServiceType.new(service_type_params)
    @service_type.save!
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @service_type = ServiceType.find(params[:id])
    @service_type.destroy
    respond_to do |format|
      format.js
    end
  end

  private
  def service_type_params
    params.require(:service_type).permit(:name, :user_id, :app_id)
  end
end

class AutosavesController < ApplicationController
  def create
    form = params[:form]
    payload = autosave_params.to_json
    @as = Autosave.find_by_form(form)
    if @as.nil?
      @as = current_app.autosaves.build(form: form, payload: payload)
    else
      @as.payload = payload
    end
    if @as.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def index
    @as = current_app.autosaves.where(form: params[:form]).first
    unless @as.nil?
      render json: @as.payload
    else
      render json: {}
    end
  end

  private
  def autosave_params
    params.require(:payload).except("0", "1", "2").permit!
  end
  
end

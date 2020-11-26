class AutosavesController < ApplicationController
  # protect_from_forgery with: :null_session
  def create
    form = params[:form]
    payload = autosave_params.to_json
    @as = Autosave.find_by_form(form)

    recipe_data(autosave_params)
    current_recipe = Recipe.find_by(name: @name, chef_id: current_app_user.chef_info.id, is_draft: false)

    if current_recipe.blank? && @name.present? && @description.present?
      recipe = Recipe.find_or_initialize_by(name: @name, chef_id: current_app_user.chef_info.id, is_draft: true)
      recipe.assign_attributes(description: @description,
                                summary: @summary,
                                price: @price,
                                subcategory_id: @subcategory_id)
      recipe.style_ids = @style_ids
      recipe.ingredient_ids = @ingredient_ids
      recipe.allergen_ids = @allergen_ids
      recipe.save!
    end

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

  def recipe_data(autosave_params)
    autosave_params.to_h.each do |key|
      key_name = key[1]['name']
      key_value = key[1]['value']
      @name = key_value if key_name.include?('name') && key_value.present?
      @summary = key_value if key_name.include?('summary') && key_value.present?
      @description = key_value if key_name.include?('description') && key_value.present?
      @price = key_value if key_name.include?('price') && key_value.present?
      @subcategory_id = key_value if key_name.include?('subcategory_id') && key_value.present?
      @style_ids = key_value if key_name.include?('style_ids') && key_value.present?
      @ingredient_ids = key_value if key_name.include?('ingredient_ids') && key_value.present?
      @allergen_ids = key_value if key_name.include?('allergen_ids') && key_value.present?
    end
  end 
end

class AutosavesController < ApplicationController
  # protect_from_forgery with: :null_session
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

    if @as
      # Parse the existing payload from JSON string to a Ruby hash
      payload = JSON.parse(@as.payload)

      # Initialize a hash to store the updated values
      updated_values = payload.dup

      # Extract the recipe_id from the payload if available
      recipe_id = nil
      payload.each do |key, value|
        if value["name"] == "recipe[id]"
          recipe_id = value["value"]
          break
        end
      end

      if recipe_id
        # Fetch the recipe to get the latest inventory_count
        recipe = Recipe.find_by(id: recipe_id)

        if recipe
          # Update the payload with the latest inventory_count
          payload.each do |key, value|
            if value["name"] == "recipe[inventory_count]"
              updated_values[key] = { "name" => value["name"], "value" => recipe.inventory_count }
            end
          end

          render json: updated_values
        end
      else
        render json: {}
      end
    end
  end

  private
  def autosave_params
    params.require(:payload).except("0", "1", "2").permit!
  end
end

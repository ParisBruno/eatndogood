class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:edit, :update, :show, :destroy]
  before_action :require_admin_or_chef, except: [:show, :index]
  before_action :require_logged_in, only: [:new, :create, :edit, :update, :destroy]
  
  def new
    @ingredient = Ingredient.new
  end
  
  def create
    @ingredient = Ingredient.new(ingredient_params)
    @ingredient.app_id = current_app.id
    if @ingredient.save
      flash[:success] = "Ingredient was successfully created"
      redirect_to app_ingredients_path(current_app)
    else
      render 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    if @ingredient.update(ingredient_params)
      flash[:success] = "Ingredient name was updated successfully"
      redirect_to app_ingredients_path(current_app)
    else
      render 'edit'
    end
  end
  
  def show
    recipes = @ingredient.recipes
    recipes = recipes.where(is_draft: false) unless current_app_user&.admin?
    @ingredient_recipes = recipes.paginate(page: params[:page], per_page: 5)
  end

  def index
    @ingredients = current_app.ingredients.paginate(page: params[:page], per_page: 5)
  end

  def destroy
    unless @ingredient.recipes.count > 0
      @ingredient.destroy
      respond_to do |format|
        format.html { redirect_to table_app_ingredients_path(current_app), notice: 'Ingredient was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to app_ingredients_path(current_app), notice: 'Ingredient has recipes and cannot be destroyed'
    end
  end

  def table
    @ingredients = Ingredient.where(app_id: current_app.id).order(:sort)
  end

  def update_positions
    params[:elements].each do |ele|
      ingredient = Ingredient.find(ele[1][:id])
      ingredient.update(sort: ele[0])
    end
    respond_to do |format|
      format.js
    end
  end

  private
  
  def ingredient_params
    # params.require(:ingredient).permit(:name, :translations_attributes)
    params.require(:ingredient).permit(*Ingredient.globalize_attribute_names + [:image])
  end
  
  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
  
  
  
end
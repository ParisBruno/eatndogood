class IngredientsController < ApplicationController
  before_action :set_apps
  before_action :set_ingredient, only: [:edit, :update, :show, :destroy]
  before_action :require_admin_or_chef, except: [:show, :index, :table]
  before_action :require_logged_in, only: [:new, :create, :edit, :update, :destroy]
  
  def new
    @ingredient = Ingredient.new
  end
  
  def create
    @ingredient = Ingredient.new(ingredient_params)
    @ingredient.app_id = current_app.id
    if @ingredient.save
      flash[:success] = t('common.successfully_created', name: 'ingredient')
      redirect_to app_ingredients_path(current_app)
    else
      render 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    if @ingredient.update(ingredient_params)
      flash[:success] = t('common.successfully_updated', name: 'ingredient')
      redirect_to app_ingredients_path(current_app)
    else
      render 'edit'
    end
  end
  
  def show
    if @ingredient.nil?
      flash[:success] = t('common.not_found', name: 'ingredient')
      redirect_to table_app_ingredients_path(current_app)
    else
      recipes = @ingredient.recipes
      recipes = recipes.where(is_draft: false) unless current_app_user&.admin?
      @ingredient_recipes = recipes.paginate(page: params[:page], per_page: 5)
    end
  end

  def index
    @ingredients = Ingredient.where(app_id: @app_ids).paginate(page: params[:page], per_page: 5)
  end

  def destroy
    unless @ingredient.recipes.count > 0
      @ingredient.destroy
      respond_to do |format|
        format.html { redirect_to table_app_ingredients_path(current_app), notice: t('common.successfully_destroyed', name: 'Ingredient') }
        format.json { head :no_content }
      end
    else
      redirect_to app_ingredients_path(current_app), notice: t('common.has_recipe_not_destroyed', name: 'Ingredient')
    end
  end

  def table
    @ingredients = Ingredient.where(app_id: @app_ids).order(:sort)
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
    @ingredient = Ingredient.where(id: params[:id], app_id: @app_ids).last
  end
end
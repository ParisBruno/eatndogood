class AllergensController < ApplicationController
  before_action :set_allergen, only: [:show, :edit, :update, :destroy]
  before_action :require_admin_or_chef, except: [:show, :index, :table]
  before_action :require_logged_in, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_chef_ids

  # GET /allergens
  # GET /allergens.json
  def index
    @allergens = Allergen.where(app_id: current_app.id).all
  end

  # GET /allergens/1
  # GET /allergens/1.json
  def show
    if @allergen.nil?
      flash[:success] = t('common.not_found', name: 'Allergen')
      redirect_to app_route(table_app_allergens_path(current_app))
    else
      recipes = Recipe.joins(:recipe_ingredients).where(chef_id: @chef_ids)
      if @allergen.recipes.present?
        recipes = recipes.where.not(id: @allergen.recipes.pluck(:id))
      end
      recipes = recipes.where(is_draft: false) unless @sessioned_user&.admin?
      @recipes = recipes.paginate(page: params[:page], per_page: 3)
    end
  end

  # GET /allergens/new
  def new
    @allergen = Allergen.new
  end

  # GET /allergens/1/edit
  def edit
  end

  # POST /allergens
  # POST /allergens.json
  def create
    @allergen = Allergen.new(allergen_params)
    @allergen.app_id = current_app.id

    if @allergen.save
      redirect_to app_route(table_app_allergens_path(current_app)), notice: t('common.successfully_created', name: 'Allergen')
    else
      render 'new'
    end
  end

  # PATCH/PUT /allergens/1
  # PATCH/PUT /allergens/1.json
  def update
    if @allergen.update(allergen_params)
      redirect_to app_route(app_allergens_path(current_app)), notice: t('common.successfully_updated', name: 'Allergen')
    else
      render 'edit'
    end
  end

  # DELETE /allergens/1
  # DELETE /allergens/1.json
  def destroy
    unless @allergen.recipes.count > 0
      @allergen.destroy
      respond_to do |format|
        format.html { redirect_to app_route(app_allergens_path(current_app)), notice: t('common.successfully_destroyed', name: 'Allergen')}
        format.json { head :no_content }
      end
    else
      redirect_to app_route(app_allergens_path(current_app)), notice: t('common.has_recipe_not_destroyed', name: 'Allergen')
    end
  end

  def table
    @allergens = Allergen.where(app_id: current_app.id).order(:sort)
  end

  def update_positions
    params[:elements].each do |ele|
      ingredient = Allergen.find(ele[1][:id])
      ingredient.update(sort: ele[0])
    end
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_allergen
      @allergen = Allergen.friendly.where(slug: params[:id], app_id: current_app.id).last
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def allergen_params
      params.require(:allergen).permit(*Allergen.globalize_attribute_names + [:image])
    end
end

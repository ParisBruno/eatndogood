class RecipesController < ApplicationController
  respond_to :html, :js
  before_action :require_logged_in, except: [:index, :show, :like]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :like]
  before_action :require_user, except: [:index, :show, :like]
  # before_action :require_same_user, only: [:edit, :update, :destroy]
  # before_action :require_user_like, only: [:like]
  before_action :set_chef_ids
  
  def index
    flash.discard
    if params[:filter]
      recipes = Recipe.where(chef_id:@chef_ids, is_draft: false).filters(params)
      if (@sessioned_user.present? && !@sessioned_user.admin? && @sessioned_user.agreement.nil?) || (@sessioned_user.nil? && cookies[:agreement].nil?)
        exercise_recipes_id = Style.agreement_style.recipes.pluck(:id)
        recipes = recipes.where.not(id: exercise_recipes_id)
      end
      @recipes = recipes.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
      if params[:allergen_ids]
        selected_allergens = params[:allergen_ids].map(&:to_i)
        allergens = Allergen.where(id: selected_allergens)
                      .map(&:name)
                      .map(&:capitalize).join(",")
        flash[:warning] = t('recipes.all_displayed_recipe_not_contain_allergen', allergens: allergens)
        @display_flash = true
      end
    else
      recipes = Recipe.where(chef_id: @chef_ids, is_draft: false)
      if (@sessioned_user.present? && !@sessioned_user.admin? && @sessioned_user.agreement.nil?) || (@sessioned_user.nil? && cookies[:agreement].nil?)
        exercise_recipes_id = Style.agreement_style.recipes.pluck(:id)
        recipes = recipes.where.not(id: exercise_recipes_id)
      end
      @recipes = recipes.order(created_at: :desc).includes(:styles).includes(:allergens).includes(:ingredients).paginate(page: params[:page], per_page: 10)
    end
  end
  
  def show
    if @recipe.nil?
      flash[:success] = t('common.not_found', name: 'Recipe')
      redirect_to app_route(app_recipes_path(current_app))
    else
      return app_route(app_recipes_path(current_app, "underdog-plan-outlines")) if ((@sessioned_user.present? && !@sessioned_user.admin? && @sessioned_user.agreement.nil?) || (@sessioned_user.nil? && cookies[:agreement].nil?)) && @recipe.styles.map{|x| x.id}.include?(138)
      @comment = Comment.new
      @comments = @recipe.comments.paginate(page: params[:page], per_page: 5)
    end
  end
  
  def new
    @recipe = Recipe.new 
    @style = @recipe.styles.build
    @allergen = @recipe.allergens.build
    @ingredient = @recipe.ingredients.build
    # byebug
    @categories = Category.all
  end
  
  def create
    selected_locale = params['recipe']['locale']
    name = recipe_params["name_#{selected_locale}"]
    @recipe = Recipe.find_or_initialize_by(name: name, chef_id: @sessioned_user.chef_info.id)
    @recipe.assign_attributes(recipe_params)
    @recipe.name = name
    @recipe.description = recipe_params["description_#{selected_locale}"]
    if params['commit'] == t('recipes.save_submit')
      @recipe.is_draft = false
    elsif params['commit'] == t('recipes.save_draft')
      @recipe.is_draft = true
    end
    if @recipe.save && @recipe.styles.present?
      # upload_images
      delete_draft
      flash[:success] = t('common.successfully_created', name: 'Recipe')
      redirect_to app_route(app_recipe_path(current_app, @recipe))
    else
      redirect_to app_route(new_app_recipe_path(current_app, @recipe)), alert: t('recipes.choose_category')
    end
  end
  
  def edit
    @style = @recipe.styles.build
    @allergen = @recipe.allergens.build
    @ingredient =  @recipe.ingredients.build
    @categories = Category.all
  end

  def email_question

  end
  
  def send_email_question

  end
  
  def update
    if params['commit'] == t('recipes.save_submit')
      @recipe.is_draft = false
    elsif params['commit'] == t('recipes.save_draft')
      @recipe.is_draft = true
    end
    if @recipe.update(recipe_params) && @recipe.styles.present?
      # upload_images
      make_tags
      delete_draft
      flash[:success] =  t('common.successfully_updated', name: 'Recipe')
      redirect_to app_route(app_recipe_path(current_app, @recipe))
    else
      redirect_to app_route(edit_app_recipe_path(current_app, @recipe)), alert: t('recipes.choose_style')
    end
  end
  
  def destroy
    @recipe.destroy
    flash[:success] = t('common.successfully_destroyed', name: 'Recipe')
    redirect_to app_route(app_recipes_path(current_app))
  end
  
  def like
    like = Like.create(like: params[:like], app: current_app, recipe: @recipe)
    if like.valid?
      flash[:success] = t('recipes.suuccessfully_selected')
      redirect_back fallback_location: app_route(app_path(current_app))
    else
      flash[:danger] = t('flash.you_can_like_dislike_once')
      redirect_back fallback_location: app_route(app_path(current_app))
    end
  end

  def drafts
    @recipes = Recipe.where(chef_id: @chef_ids, is_draft: true).order(created_at: :desc).includes(:styles).includes(:allergens).includes(:ingredients).paginate(page: params[:page], per_page: 10)
  end
  
  private

    def make_tags
      @recipe.tag_list = (@recipe.styles.pluck(:name) + @recipe.ingredients.pluck(:name) + @recipe.allergens.pluck(:name)).map(&:inspect).join(', ')
     
      @recipe.save
    end

    # def upload_images
    #   if params[:food_image]
    #     remove_old_images('food')
    #     @recipe.recipe_images.create(image: params[:food_image], img_type: 'food')
    #   end

    #   if params[:drink_image]
    #     remove_old_images('drink')
    #     @recipe.recipe_images.create(image: params[:drink_image], img_type: 'drink')
    #   end

    # end

    # def remove_old_images(type)
    #   images = @recipe.recipe_images.select{|image| image.img_type == type }
    #   images.each do |im|
    #     im.destroy
    #   end
    # end
  
    def set_recipe
      users = current_app.created_from == "fundraise" ? User.where(app_id: [current_app.id, App.fundraise.id]) : current_app.users
      chef_ids = users.includes(:chef_info).pluck("chefs.id")
      @recipe = Recipe.joins(chef: [user: :app]).friendly.where(slug: params[:id], apps: { parent_type: current_app.parent_type }, chefs: { id: chef_ids }).last
    end
  
    def recipe_params
      permitted = Recipe.globalize_attribute_names + [:food_image, :is_subscription, :enable_reservation,:enable_gift_card, :gift_card_image, :drink_image, :price, :subcategory_id, ingredient_ids: [], allergen_ids: [], style_ids: []]
      params.require(:recipe).permit(*permitted)
    end

    # def recipe_image_params
    #   params.require(:recipe_images).permit(:image)
    # end
    
    def require_same_user
      if @sessioned_user != @recipe.chef.user
        redirect_to app_route(app_recipes_path(current_app)), alert: t('recipes.edit_delete_own_recipe')
      end  
    end
    
    def require_user_like
      if !@sessioned_user
        flash[:danger] = t('flash.you_must_be_logged_in')
        redirect_to :back
      end
    end

    def delete_draft(recipe=nil)
      if recipe.nil?
        url = "/#{current_app.slug}/recipes"
      else
        url =  "/#{current_app.slug}/recipes/#{recipe.id}"
      end
      as = current_app.autosaves.where(form: url)
      if as
        as.destroy_all
      end
    end
end
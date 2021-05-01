class RecipesController < ApplicationController
  respond_to :html, :js
  before_action :require_logged_in
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :like]
  before_action :require_user, except: [:index, :show, :like]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  before_action :require_user_like, only: [:like]
  before_action :set_chef_ids
  before_action :check_limit_recipes, only: [:new, :create]
  
  def index
    flash.discard
    if params[:filter]
      @recipes = Recipe.where(chef_id:@chef_ids, is_draft: false).filters(params).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
      if params[:allergen_ids]
        selected_allergens = params[:allergen_ids].map(&:to_i)
        allergens = Allergen.where(id: selected_allergens)
                      .map(&:name)
                      .map(&:capitalize).join(",")
        flash[:warning] = "All displayed recipes do not contain #{allergens}"
        @display_flash = true
      end
    else
      # @recipes = Recipe.where(chef_id: @chef_ids).order(created_at: :desc).includes(:styles).includes(:allergens).includes(:ingredients).includes(:recipe_images).paginate(page: params[:page], per_page: 5)
      @recipes = Recipe.where(chef_id: @chef_ids, is_draft: false).order(created_at: :desc).includes(:styles).includes(:allergens).includes(:ingredients).paginate(page: params[:page], per_page: 10)
    end
  end
  
  def show
    @comment = Comment.new
    @comments = @recipe.comments.paginate(page: params[:page], per_page: 5)
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
    @recipe = Recipe.find_or_initialize_by(name: name, chef_id: current_app_user.chef_info.id)
    @recipe.assign_attributes(recipe_params)
    @recipe.name = name
    @recipe.summary = recipe_params["summary_#{selected_locale}"]
    @recipe.description = recipe_params["description_#{selected_locale}"]
    @recipe.is_draft = true if params['commit'] == t('recipes.save_draft')
    if @recipe.save && @recipe.styles.present?
      # upload_images
      delete_draft
      flash[:success] = "Recipe was created successfully!"
      redirect_to app_recipe_path(current_app, @recipe)
    else
      redirect_to new_app_recipe_path(current_app, @recipe), alert: t('recipes.choose_style')
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
      flash[:success] = "Recipe was updated successfully!"
      redirect_to app_recipe_path(current_app, @recipe)
    else
      redirect_to edit_app_recipe_path(current_app, @recipe), alert: t('recipes.choose_style')
    end
  end
  
  def destroy
    Recipe.find(params[:id]).destroy
    flash[:success] = "Recipe deleted successfully"
    redirect_to app_recipes_path(current_app)
  end
  
  def like
    like = Like.create(like: params[:like], app: current_app, recipe: @recipe)
    if like.valid?
      flash[:success] = "Your selection was succesful"
      redirect_back fallback_location: app_path(current_app)
    else
      flash[:danger] = "You can only like/dislike a recipe once"
      redirect_back fallback_location: app_path(current_app)
    end
  end

  def drafts
    @recipes = Recipe.where(chef_id: @chef_ids, is_draft: true).order(created_at: :desc).includes(:styles).includes(:allergens).includes(:ingredients).paginate(page: params[:page], per_page: 10)
  end
  
  private

    def check_limit_recipes
      recipes_count = Recipe.where(chef_id: @chef_ids).count

      recipes_limit = current_app.plan.recipes_limit

      if !recipes_limit.nil? && recipes_count >= recipes_limit
        flash[:danger] = "Your account has already reached limit the number of recipes. To add more recipe, please upgrade your plan."
        redirect_to recipes_path
      end
    end

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
      # @recipe = Recipe.includes(:recipe_images).find(params[:id])
      @recipe = Recipe.find(params[:id])
    end
  
    def recipe_params
      permitted = Recipe.globalize_attribute_names + [:food_image, :drink_image, :price, :subcategory_id, ingredient_ids: [], allergen_ids: [], style_ids: []]
      params.require(:recipe).permit(*permitted)
    end

    # def recipe_image_params
    #   params.require(:recipe_images).permit(:image)
    # end
    
    def require_same_user
      if current_app_user != @recipe.chef.user
        flash[:danger] = "You can only edit or delete your own recipes"
        redirect_to app_recipes_path(current_app)
      end  
    end
    
    def require_user_like
      if !app_user_signed_in?
        flash[:danger] = "You must be logged in to perform that action"
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
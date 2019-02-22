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
    if params[:filter]
      @recipes = Recipe.where(chef_id:@chef_ids).filters(params).order(created_at: :desc).paginate(page: params[:page], per_page: 5)
     
    else
      @recipes = Recipe.where(chef_id: @chef_ids).order(created_at: :desc).includes(:styles).includes(:allergens).includes(:ingredients).includes(:recipe_images).paginate(page: params[:page], per_page: 5)
    end
  end
  
  def show
    @comment = Comment.new
    @comments = @recipe.comments.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @recipe = Recipe.new
  end
  
  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.chef_id = current_user.chef_info.id
    if @recipe.save
      upload_images
      flash[:success] = "Recipe was created successfully!"
      redirect_to recipe_path(@recipe)
    else
      render 'new'
    end
  end
  
  def edit
    
  end

  def email_question

  end
  
  def send_email_question

  end
  
  def update
    
    if @recipe.update(recipe_params)
      upload_images
      make_tags
      flash[:success] = "Recipe was updated successfully!"
      redirect_to recipe_path(@recipe)
    else
      render 'edit'
    end
  end
  
  def destroy
    Recipe.find(params[:id]).destroy
    flash[:success] = "Recipe deleted successfully"
    redirect_to recipes_path
  end
  
  def like
    like = Like.create(like: params[:like], user_id: current_user.id, recipe: @recipe)
    if like.valid?
      flash[:success] = "Your selection was succesful"
      redirect_back fallback_location: root_path
    else
      flash[:danger] = "You can only like/dislike a recipe once"
      redirect_back fallback_location: root_path
    end
  end
  
  private

    def check_limit_recipes
      recipes_count = Recipe.where(chef_id: @chef_ids).count

      recipes_limit = @admin.plan.recipes_limit

      if recipes_count >= recipes_limit
        flash[:danger] = "Your account has already reached limit the number of recipes. To add more recipe, please upgrade your plan."
        redirect_to recipes_path
      end
    end

    def set_chef_ids
      @admin = User.find(@admin_id)
      @chef_ids = @admin.chefs.pluck(:id)
    end

    def make_tags
      @recipe.tag_list = (@recipe.styles.pluck(:name) + @recipe.ingredients.pluck(:name) + @recipe.allergens.pluck(:name)).map(&:inspect).join(', ')
     
      @recipe.save
    end

    def upload_images
      if params[:images]
        params[:images].each do |image|
          @recipe.recipe_images.create(image: image)
        end
      end
    end
  
    def set_recipe
      @recipe = Recipe.includes(:recipe_images).find(params[:id])
    end
  
    def recipe_params
      params.require(:recipe).permit(:name, :description, :summary, :image, ingredient_ids: [], allergen_ids: [], style_ids: [])
    end

    def recipe_image_params
      params.require(:recipe_images).permit(:image)
    end
    
    def require_same_user
      if current_user != @recipe.chef and !current_user.admin?
        flash[:danger] = "You can only edit or delete your own recipes"
        redirect_to recipes_path
      end  
    end
    
    def require_user_like
      if !user_signed_in?
        flash[:danger] = "You must be logged in to perform that action"
        redirect_to :back
      end
    end
end
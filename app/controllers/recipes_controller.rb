class RecipesController < ApplicationController
  before_action :require_logged_in
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :like]
  before_action :require_user, except: [:index, :show, :like]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  before_action :require_user_like, only: [:like]
  
  def index
    @recipes = Recipe.paginate(page: params[:page], per_page: 5)
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
    @recipe.chef = current_chef
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
    like = Like.create(like: params[:like], chef: current_chef, recipe: @recipe)
    if like.valid?
      flash[:success] = "Your selection was succesful"
      redirect_back fallback_location: root_path
    else
      flash[:danger] = "You can only like/dislike a recipe once"
      redirect_back fallback_location: root_path
    end
  end
  
  private

    def upload_images
      if params[:images]
        params[:images].each { |image|
          @recipe.recipe_images.create(image: image)
        }
      end
    end
  
    def set_recipe
      @recipe = Recipe.includes(:recipe_images).find(params[:id])
    end
  
    def recipe_params
      params.require(:recipe).permit(:name, :description, :image, ingredient_ids: [])
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
      if !logged_in?
        flash[:danger] = "You must be logged in to perform that action"
        redirect_to :back
      end
    end
end
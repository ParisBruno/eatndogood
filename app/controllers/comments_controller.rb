class CommentsController < ApplicationController
  before_action :require_user
  
  def create
    @recipe = Recipe.find(params[:recipe_id])
    @comment = @recipe.comments.build(comment_params)
    @comment.chef = current_chef
    if @comment.save
      ActionCable.server.broadcast "comments", render(partial: 'comments/comment', object: @comment)
      # flash[:success] = "Comment was created successfully"
      # redirect_to recipe_path(@recipe)
    else
      flash[:danger] = t('flash.comment_not_created')
      redirect_to :back
    end
  end
  
  private
  
  def comment_params
    params.require(:comment).permit(:description)
  end
  
end
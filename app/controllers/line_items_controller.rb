class LineItemsController < ApplicationController
  skip_before_action :set_app, :check_app_user, :set_header_data

  def create
    @recipe = Recipe.find(params[:recipe_id])
  
    if @current_cart.recipes.include?(@recipe)
      @line_item = @current_cart.line_items.find_by(recipe_id: @recipe.id)
      @line_item.quantity += 1
    else
      @line_item = LineItem.new
      @line_item.cart = @current_cart
      @line_item.recipe = @recipe
    end

    flash[:success] = I18n.t 'flash.recipe_add_to_cart' if @line_item.save
    redirect_to app_recipe_path(current_app, @recipe.id)
  end

  private

  def line_item_params
    params.require(:line_item).permit(:quantity, :recipe_id, :cart_id)
  end
end

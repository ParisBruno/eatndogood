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

  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    respond_to do |format|
      set_delivery_and_tax
      format.html { redirect_to app_cart_path(current_app, @current_cart) }
      format.js
    end
  end

  def add_quantity
    @line_item = LineItem.find(params[:id])
    @line_item.quantity += 1

    respond_to do |format|
      if @line_item.save
        set_delivery_and_tax
        format.html { redirect_to app_cart_path(current_app, @current_cart) }
        format.js
      else
        format.html { render action: 'new' and return }
      end
    end
  end
  
  def reduce_quantity
    @line_item = LineItem.find(params[:id])
    if @line_item.quantity > 1
      @line_item.quantity -= 1
    end

    respond_to do |format|
      if @line_item.save
        set_delivery_and_tax
        format.html { redirect_to app_cart_path(current_app, @current_cart) }
        format.js
      else
        format.html { render action: 'new' and return }
      end
    end
  end

  private

  def line_item_params
    params.require(:line_item).permit(:quantity, :recipe_id, :cart_id)
  end
end

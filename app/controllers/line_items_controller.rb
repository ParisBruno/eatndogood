class LineItemsController < ApplicationController
  # respond_to :html, :js
  skip_before_action :set_app, :check_app_user, :set_header_data

  def create
    # Find associated product and current cart
    # chosen_product = Product.find(params[:product_id])
    @recipe = Recipe.find(params[:recipe_id])
    # current_cart = @current_cart
  
    # If cart already has this product then find the relevant line_item and iterate quantity otherwise create a new line_item for this product
    if @current_cart.recipes.include?(@recipe)
      # Find the line_item with the chosen_product
      @line_item = @current_cart.line_items.find_by(recipe_id: @recipe.id)
      # Iterate the line_item's quantity by one
      @line_item.quantity += 1
    else
      @line_item = LineItem.new
      @line_item.cart = @current_cart
      @line_item.recipe = @recipe
      # @line_item.order_id = 1
    end
    # Save and redirect to cart show path
    flash[:success] = I18n.t 'flash.recipe_add_to_cart' if @line_item.save
    redirect_to app_recipe_path(current_app, @recipe.id)
  end


  def destroy
    # @recipe = Recipe.find(params[:recipe_id])
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    respond_to do |format|
      # if @line_item.save
        format.html { redirect_to app_recipe_path(current_app, params[:recipe_id]) }
        format.js
        # format.json { render action: 'show', status: :created, location: @line_item }
      # else
      #   format.html { render action: 'new' }
      #   # format.json { render json: @line_item.errors, status: :unprocessable_entity }
      # end
    end

    # @line_item.save
    # redirect_to app_recipe_path(current_app, params[:recipe_id])
  end

  def add_quantity
    # @recipe = Recipe.find(params[:recipe_id])
    @line_item = LineItem.find(params[:id])
    @line_item.quantity += 1

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to app_recipe_path(current_app, params[:recipe_id]) }
        format.js
        # format.json { render action: 'show', status: :created, location: @line_item }
      else
        format.html { render action: 'new' and return }
        # format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
    # redirect_to app_recipe_path(current_app, params[:recipe_id])
  end
  
  def reduce_quantity
    # @recipe = Recipe.find(params[:recipe_id])
    @line_item = LineItem.find(params[:id])
    if @line_item.quantity > 1
      @line_item.quantity -= 1
    end
    # @line_item.save

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to app_recipe_path(current_app, params[:recipe_id]) }
        format.js
        # format.json { render action: 'show', status: :created, location: @line_item }
      else
        format.html { render action: 'new' and return }
        # format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
    # redirect_to app_recipe_path(current_app, params[:recipe_id])
  end
  
  private

  def line_item_params
    params.require(:line_item).permit(:quantity, :recipe_id, :cart_id)
  end
end

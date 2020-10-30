class LineItemsController < ApplicationController
  skip_before_action :set_app, :check_app_user, :set_header_data

  def create
    # Find associated product and current cart
    # chosen_product = Product.find(params[:product_id])
    # byebug
    @chosen_recipe = Recipe.find(params[:recipe_id])
    # current_cart = @current_cart
  
    # If cart already has this product then find the relevant line_item and iterate quantity otherwise create a new line_item for this product
    if @current_cart.recipes.include?(@chosen_recipe)
      # Find the line_item with the chosen_product
      @line_item = @current_cart.line_items.find_by(recipe_id: @chosen_recipe.id)
      # Iterate the line_item's quantity by one
      @line_item.quantity += 1
    else
      @line_item = LineItem.new
      @line_item.cart = @current_cart
      @line_item.recipe = @chosen_recipe
      @line_item.order_id = 1
    end
    # Save and redirect to cart show path
    # @line_item.save
    # redirect_to app_cart_path(current_cart)
    # redirect_to app_recipe_path(current_app, @chosen_recipe.id)
    respond_to do |format|
      if @line_item.save
        format.html { redirect_to app_recipe_path(current_app, @chosen_recipe.id) }
        format.js
        # format.html { redirect_to app_recipe_path(current_app, @chosen_recipe.id) }
        
        # format.json { render action: 'show', status: :created, location: @line_item }
      else
        format.html { render action: 'new' and return }
        # format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # respond_to do |format|
  #   if @line_item.save
  #     format.html { redirect_to @line_item.cart, notice: 'Line item was successfully created.' }
  #     format.json { render action: 'show', status: :created, location: @line_item }
  #   else
  #     format.html { render action: 'new' }
  #     format.json { render json: @line_item.errors, status: :unprocessable_entity }
  #   end
  # end

  def destroy
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
    # redirect_to app_recipe_path(current_app, params[:recipe_id])
  end

  def add_quantity
    @line_item = LineItem.find(params[:id])
    @line_item.quantity += 1
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
  
  def reduce_quantity
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

class LineItemsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]
  skip_before_action :set_app, :check_app_user, :set_header_data

  def create
    @gift_card = GiftCard.find_by(id: params[:gift_card_id])
    if @gift_card
      if @current_cart.gift_cards.include?(@gift_card)
        @line_item = @current_cart.line_items.find_by(gift_card_id: @gift_card.id)
        @line_item.quantity += 1
      else
        @line_item = LineItem.new
        @line_item.cart = @current_cart
        @line_item.gift_card = @gift_card
      end

      flash[:success] = I18n.t 'flash.gift_add_to_cart' if @line_item.save
      redirect_to new_app_gift_card_path(current_app)
      return
    end

    @recipe = Recipe.find_by(id: params[:recipe_id])
  
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

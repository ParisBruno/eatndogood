class CartsController < ApplicationController
  def show
    @current_cart
  end

  def destroy
    @current_cart
    @current_cart.destroy
    session[:cart_id] = nil
    # respond_to do |format|
    #   format.html { redirect_to store_url, notice: 'Теперь ваша корзина пуста!' }
    #   format.json { head :no_content }
    # end
    redirect_to app_recipe_path(current_app, params[:recipe_id])
  end
end

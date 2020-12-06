class GiftCardsController < ApplicationController

  def new
    @gift_card = GiftCard.new
  end

  def create
    if gift_card_params[:price].to_i > 0
      price = gift_card_params[:price]
    else
      price = gift_card_params[:other_price]
    end

    @gift_card = GiftCard.create!(user_id: current_app_user.id,
                                    price: price,
                                    purchaser_name: current_app_user.full_name,
                                    purchaser_email: current_app_user.email,
                                    client_name: gift_card_params[:client_name],
                                    client_email: gift_card_params[:client_email],
                                    description: gift_card_params[:description]
                                  )
    @gift_card.name = generate_name(@gift_card.id)
    @gift_card.save!

    redirect_post line_items_path(gift_card_id: @gift_card.id)
  end

  private

  def generate_name(gift_card_id)
    'MYTR' + format('%04d', gift_card_id)
  end

  def gift_card_params
    params.require(:gift_card).permit(:price, :other_price, :client_name, :client_email, :confrim_client_email, :description)
  end
end

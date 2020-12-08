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
    @gift_card.name = generate_name
    @gift_card.save!

    redirect_post line_items_path(gift_card_id: @gift_card.id)
  end

  private

  def generate_name
    date = Date.current.strftime("%m%d%y")
    today_gift_cards = GiftCard.where('name LIKE ?', "EnDG#{date}%")
    if today_gift_cards.empty?
      'EnDG' + date + '01'
    else
      last_today_gift = today_gift_cards.last
      next_today_gift = last_today_gift.name.last(2).to_i + 1
      next_today_gift_to_string = next_today_gift.to_s
      next_today_gift_to_string = '0' + next_today_gift_to_string if next_today_gift_to_string.length == 1
      'EnDG' + date + next_today_gift_to_string
    end
  end

  def gift_card_params
    params.require(:gift_card).permit(:price, :other_price, :client_name, :client_email, :confrim_client_email, :description)
  end
end

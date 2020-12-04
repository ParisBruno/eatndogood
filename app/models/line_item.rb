# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :gift_card, optional: true
  belongs_to :cart
  belongs_to :order, optional: true

  def total_price
    if self.recipe
      self.quantity * self.recipe.price
    elsif self.gift_card
      self.quantity * self.gift_card.price
    end
  end
end

# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :gift_card, optional: true
  belongs_to :cart, optional: true
  belongs_to :order, optional: true

  accepts_nested_attributes_for :recipe

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }

  def total_price
    if self.recipe
      self.quantity * self.recipe.price
    elsif self.gift_card
      self.quantity * self.gift_card.price
    end
  end
end

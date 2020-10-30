# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :recipe
  belongs_to :cart
  belongs_to :order

  def total_price
    self.quantity * self.recipe.price
  end
end

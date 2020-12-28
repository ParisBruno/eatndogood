# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :line_items
  has_many :recipes, through: :line_items
  has_many :gift_cards, through: :line_items

  def show
    @cart = @current_cart
  end

  def sub_total
    sum = 0
    self.line_items.each do |line_item|
      sum+= line_item.total_price unless line_item.recipe&.is_draft
    end
    return sum
  end
end

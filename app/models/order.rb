# frozen_string_literal: true

class Order < ApplicationRecord
  attr_accessor :coupon_percent_off, :gift_card_id

  has_many :line_items, dependent: :destroy, inverse_of: :order
  has_many :recipes, through: :line_items

  validates :email, presence: true
  validates :phone, presence: true

  enum status: { active: 0, closed: 1 }

  accepts_nested_attributes_for :line_items, reject_if: :all_blank, allow_destroy: true

  def sub_total
    sum = 0
    self.line_items.each do |line_item|
      sum+= line_item.total_price unless line_item.recipe&.is_draft
    end
    return sum
  end
end

# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :gift_card, optional: true
  belongs_to :cart, optional: true
  belongs_to :order, optional: true

  accepts_nested_attributes_for :recipe

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }

  after_save :set_amount_data

  def total_price
    if self.recipe
      self.quantity * self.recipe.price
    elsif self.gift_card
      self.quantity * self.gift_card.price
    end
  end

  def set_amount_data
    if order
      sub_total = if recipe
                     quantity * recipe.price
                  elsif gift_card
                     quantity * gift_card.price
                  end

      total_tax = if recipe && recipe.is_draft == false
                     sub_total * (recipe.chef.user.product_tax/100)
                  elsif gift_card
                     quantity * 3.95
                  end
   
      coupon_discount = if order.coupon_code.present?
                           coupon_code = CouponCode.find_by(title: order.coupon_code)
                           sub_total * (-1) * (coupon_code.coupon_percent_off.to_f/100)
                        else
                           0.0
                        end

      amount = ((sub_total + coupon_discount + total_tax) * 100).to_i

      update_columns(amount: amount, sub_total: (sub_total * 100).to_i,
                     total_tax: total_tax.to_f, coupon_discount: coupon_discount.to_f)
    end
  end
end

# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :gift_card, optional: true
  belongs_to :cart, optional: true
  belongs_to :order, optional: true

  accepts_nested_attributes_for :recipe

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }
  validate :quantity_less_than_or_equal_to_inventory_count
  validates_length_of :quantity, :maximum => 4

  after_save :set_amount_data
  after_destroy :increase_inventory_count, if: -> { self.order.present? && recipe.present? && recipe.is_inventory_count && recipe.inventory_count.nonzero? }
  after_create :decrease_inventory_count, if: -> { self.order.present? && recipe.present? && recipe.is_inventory_count && recipe.inventory_count.nonzero? }
  before_update :adjust_inventory_count, if: -> { self.order.present? && recipe.present? && recipe.is_inventory_count && recipe.inventory_count.nonzero? }

  def total_price
    if self.recipe
      self.quantity.to_f * self.recipe.price.to_f
    elsif self.gift_card
      self.quantity.to_f * self.gift_card.price.to_f
    end
  end

  def set_amount_data
    if order
      sub_total = if recipe
                     quantity.to_f * recipe.price.to_f
                  elsif gift_card
                     quantity.to_f * gift_card.price.to_f
                  end

      total_tax = if recipe && recipe.is_draft == false
                     sub_total.to_f * (recipe.chef.user.product_tax.to_f/100)
                  elsif gift_card
                     quantity * 3.95
                  end
   
      coupon_discount = if order.coupon_code.present?
                           coupon_code = CouponCode.find_by(title: order.coupon_code)
                           !coupon_code.coupon_amount_off.zero? ? (coupon_code.coupon_amount_off * (-1)) : (sub_total * (-1) * (coupon_code.coupon_percent_off.to_f/100))
                        else
                           0.0
                        end

      amount = ((sub_total.to_f + coupon_discount.to_f + total_tax.to_f) * 100).to_i

      update_columns(amount: amount, sub_total: (sub_total.to_f * 100).to_i,
                     total_tax: total_tax.to_f, coupon_discount: coupon_discount.to_f)
    end
  end

  private

  def increase_inventory_count
    inventory_count = recipe.inventory_count + quantity
    recipe.update(inventory_count: inventory_count)
    update_autosave
  end

  def decrease_inventory_count
    inventory_count = recipe.inventory_count - quantity
    recipe.update(inventory_count: inventory_count)
    update_autosave
  end

  def adjust_inventory_count
    return if errors.present?
    if order_id_was != order_id
      inventory_count = recipe.inventory_count - quantity
    elsif quantity_was < quantity
      inventory_count = recipe.inventory_count - (quantity - quantity_was)
    elsif quantity_was > quantity
      inventory_count = recipe.inventory_count + (quantity_was - quantity)
    else
      inventory_count = recipe.inventory_count
    end

    if inventory_count != recipe.inventory_count_was
      recipe.update(inventory_count: inventory_count)
      update_autosave
    end
  end

  def update_autosave
    app = order.user.app
    url = "/recipes/#{recipe.slug}"
    as = app.autosaves.where(form: url).last
    if as.present?
      payload = JSON.parse as.payload
      payload["22"]["value"] = recipe.inventory_count
      as.update(payload: payload.to_json)
    end
  end

  def quantity_less_than_or_equal_to_inventory_count
    if recipe.present? && recipe.is_inventory_count.present? && quantity > recipe.inventory_count
      errors.add(:base, "Only #{recipe.inventory_count} left!")
    end
  end
end

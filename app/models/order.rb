# frozen_string_literal: true

class Order < ApplicationRecord
  attr_accessor :coupon_percent_off, :coupon_amount_off, :gift_card_id, :password, :password_confirmation, :app_id

  has_many :line_items, dependent: :destroy, inverse_of: :order
  has_many :recipes, through: :line_items
  has_one :delivery, dependent: :destroy
  belongs_to :user

  scope :active_of_day, ->(user_ids) { where(user_id: user_ids, status: 0).where('orders.created_at >= ?', Date.today.beginning_of_day) }
  scope :closed_of_day, ->(user_ids) { where(user_id: user_ids, status: 1).where('orders.created_at >= ?', Date.today.beginning_of_day) }

  enum status: { active: 0, archived: 1 }

  accepts_nested_attributes_for :line_items, reject_if: :reject_line_item_if_blank, allow_destroy: true

  def sub_total
    sum = 0
    self.line_items.each do |line_item|
      sum+= line_item.total_price.to_f unless line_item.recipe&.is_draft
    end
    return sum
  end

  private

  def reject_line_item_if_blank(attributes)
    return false if attributes['recipe_id'].present? || attributes['gift_card_id'].present?
    true
  end
end

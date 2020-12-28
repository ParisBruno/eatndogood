# frozen_string_literal: true

class CouponCode < ApplicationRecord
  belongs_to :chef

  validates :title, presence: true
  validates :coupon_percent_off, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end

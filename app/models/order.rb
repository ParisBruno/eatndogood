# frozen_string_literal: true

class Order < ApplicationRecord
  attr_accessor :coupon_percent_off, :gift_card_id

  has_many :line_items, dependent: :destroy

  validates :email, presence: true
  validates :phone, presence: true
end

# frozen_string_literal: true

class GiftCard < ApplicationRecord
  attr_accessor :confrim_client_email, :other_price
  
  belongs_to :user
  has_many :line_items, dependent: :destroy

  def reduce_price(amount)
    self.price = self.price - amount
    self.last_used_date = DateTime.now
    self.save
  end

  def to_active
    self.is_active = true
    self.save
  end
end

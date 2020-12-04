# frozen_string_literal: true

class GiftCard < ApplicationRecord
  attr_accessor :confrim_client_email, :other_price
  
  belongs_to :user
  has_many :line_items, dependent: :destroy
end

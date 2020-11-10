# frozen_string_literal: true

class Order < ApplicationRecord
  attr_accessor :coupon_code

  has_many :line_items, dependent: :destroy

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :phone, uniqueness: true, allow_nil: true
end

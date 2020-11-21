# frozen_string_literal: true

class FundrasingCode < ApplicationRecord
  belongs_to :chef

  validates :title, presence: true
end

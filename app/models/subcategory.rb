# frozen_string_literal: true

class Subcategory < ApplicationRecord
  belongs_to :category
  # belongs_to :recipe
end

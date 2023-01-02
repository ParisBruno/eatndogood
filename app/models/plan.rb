# frozen_string_literal: true
class Plan < ApplicationRecord
  has_many :apps
  belongs_to :plan_category

  validates :title, presence: true, uniqueness: true

end

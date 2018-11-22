# frozen_string_literal: true
class Plan < ApplicationRecord
  has_many :users

  validates :title, presence: true, uniqueness: true
end

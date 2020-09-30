# frozen_string_literal: true
class Like < ApplicationRecord
  belongs_to :app
  belongs_to :recipe
  
  validates_uniqueness_of :app, scope: :recipe
end

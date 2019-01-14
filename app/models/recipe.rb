# frozen_string_literal: true
class Recipe < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 5, maximum: 500 }
  belongs_to :chef
  validates :chef_id, presence: true
  default_scope -> { order(updated_at: :desc)} 
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_and_belongs_to_many :allergens
  #has_many :recipe_allergens
  #has_many :allergens, through: :recipe_allergens
  #mount_uploader :image, ImageUploader

  has_attached_file :image, styles: { thumb: "300x300>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  
  def thumbs_up_total
    self.likes.where(like: true).size
  end
  
  def thumbs_down_total
    self.likes.where(like: false).size    
  end
end

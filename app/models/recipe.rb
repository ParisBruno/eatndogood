# frozen_string_literal: true
class Recipe < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  belongs_to :chef
  validates :chef_id, presence: true
  default_scope -> { order(updated_at: :desc)} 
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :recipe_images, dependent: :destroy
  has_and_belongs_to_many :allergens
  has_and_belongs_to_many :styles
  has_many :questions
  has_many :reservations, dependent: :destroy
  #has_many :recipe_allergens
  #has_many :allergens, through: :recipe_allergens
  #mount_uploader :image, ImageUploader

  accepts_nested_attributes_for :recipe_images

  acts_as_ordered_taggable

  #after_create :make_tags
  after_create :make_tags

  
  def thumbs_up_total
    self.likes.where(like: true).size
  end
  
  def thumbs_down_total
    self.likes.where(like: false).size    
  end

  def is_reservation_enable
    entrepreneur_plan_ids = PlanCategory.where(name: 'Entrepreneurs').first.plans.pluck(:id)
    return true if entrepreneur_plan_ids.include? self.chef.user.plan_id
    
    entrepreneur_plan_ids.include?  self.chef.admin_user.plan_id if self.chef.admin_user.present?

  end

  def self.filters params
    puts params
    styles = Style.where({id: params[:style_ids]}).pluck(:name)
    ingredients = Ingredient.where({id: params[:ingredient_ids]}).pluck(:name)
    allergens = Allergen.where({id: params[:allergen_ids]}).pluck(:name)
    tags = styles + ingredients + allergens
    
    Recipe.includes(:styles).includes(:ingredients).includes(:allergens).tagged_with(tags, :any => true)
  end

  def food_images
    self.recipe_images.select {|image| image.img_type == "food" }
  end

  def drink_images
    self.recipe_images.select {|image| image.img_type == "drink" }
  end

  private

  def make_tags
    self.tag_list = self.styles.pluck(:name) + self.ingredients.pluck(:name) + self.allergens.pluck(:name)
    self.save
  end

end

# frozen_string_literal: true
class Recipe < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  belongs_to :chef
  validates :chef_id, presence: true
  default_scope -> { order(updated_at: :desc)}
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  # has_many :recipe_images, dependent: :destroy
  # has_many :food_images, -> { where('img_type = ?', 'food') }
  # has_many :drink_images, -> { where('img_type = ?', 'drink') }
  has_and_belongs_to_many :allergens, dependent: :destroy
  has_and_belongs_to_many :styles, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_one :subcategory
  #has_many :recipe_allergens
  #has_many :allergens, through: :recipe_allergens
  #mount_uploader :image, ImageUploader

  has_one_attached :food_image
  has_one_attached :drink_image
  has_one_attached :gift_card_image

  validates :food_image, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}
  validates :drink_image, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}
  validates :gift_card_image, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}
  validates :styles, presence: true
  validates :name, :uniqueness => { case_sensitive: false, scope: :chef_id }
  # accepts_nested_attributes_for :recipe_images

  acts_as_ordered_taggable

  #after_create :make_tags
  after_create :make_tags

  translates :name, :description, fallbacks_for_empty_translations: true
  globalize_accessors locales: I18n.available_locales, attributes: [:name, :description]

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.sizes
    {
      medium: "500x500",
      thumb: "300x300"
    }
  end

  def sized(image_type, size)
    self.send(image_type).variant(resize: Recipe.sizes[size]).processed rescue nil
  end

  
  def thumbs_up_total
    self.likes.where(like: true).size
  end
  
  def thumbs_down_total
    self.likes.where(like: false).size    
  end

  def self.subscription_recipe(current_app)
    joins(chef: [user: :app]).where(is_subscription: true, apps: { id: current_app.id }).last
  end

  def is_reservation_enable
    entrepreneur_plan_ids = PlanCategory.where(name: 'Entrepreneurs').first.plans.pluck(:id)
    # raise entrepreneur_plan_ids.inspect
    # return true if entrepreneur_plan_ids.include? self.chef.user.app.plan_id
    
    # entrepreneur_plan_ids.include?  self.chef.admin_user.plan_id if self.chef.admin_user.present?
    entrepreneur_plan_ids.include? self.chef.user.app.plan_id
  end

  def is_ask_catering_enable
    professional_plan_ids = PlanCategory.where(name: 'Professionals').first.plans.pluck(:id)
    # return true if professional_plan_ids.include? self.chef.user.plan_id
    
    # professional_plan_ids.include?  self.chef.admin_user.plan_id if self.chef.admin_user.present?
    professional_plan_ids.include? self.chef.user.app.plan_id
  end

  def self.filters params
    # styles = Style.where({id: params[:style_ids]}).pluck(:name)
    # ingredients = Ingredient.where({id: params[:ingredient_ids]}).pluck(:name)
    # allergens = Allergen.where({id: params[:allergen_ids]}).pluck(:name)
    # tags = styles + ingredients
    
    # Recipe
    #   .includes(:styles)
    #   .includes(:ingredients)
    #   .includes(:allergens)
    #   .tagged_with(tags, :any => true)
    #   .tagged_with(allergens, :exclude => true)
    query =  Recipe
      .includes(:styles)
      .includes(:ingredients)
      .includes(:allergens)
    query = query.where(styles: {id: params[:style_ids]}) if params[:style_ids]
    query = query.where(ingredients: {id: params[:ingredient_ids]}) if params[:ingredient_ids]
    query = query.where.not(allergens: {id: params[:allergen_ids]}) if params[:allergen_ids]
    query
  end

  # def food_images
  #   self.recipe_images.select {|image| image.img_type == "food" }
  # end

  # def drink_images
  #   self.recipe_images.select {|image| image.img_type == "drink" }
  # end

  private

  def make_tags
    self.tag_list = self.styles.pluck(:name) + self.ingredients.pluck(:name) + self.allergens.pluck(:name)
    self.save
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

end

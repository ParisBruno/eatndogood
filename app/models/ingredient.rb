# frozen_string_literal: true
class Ingredient < ApplicationRecord
  include RailsSortable::Model
  include TranslatedUpcaser
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :app
  
  # before_destroy :no_referenced_recipes

  set_sortable :sort
  validates :name, presence: true, length: { minimum: 3, maximum: 25 }
  validates :name, :uniqueness => { case_sensitive: false, scope: :app_id }
  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients
  has_one_attached :image
  belongs_to :app
  translates :name, fallbacks_for_empty_translations: true
  globalize_accessors :locales => I18n.available_locales, :attributes => [:name]

  before_save :upcase_name

  def no_referenced_recipes
    return if recipes.empty?

    errors.add(:base, "This ingredient is used by #{self.recipes.count} recipes")
    false
  end

  def self.sizes
    {
      thumb: "300x300"
    }
  end

  def sized(image_type, size)
    self.send(image_type).variant(resize: Ingredient.sizes[size]).processed rescue nil
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end

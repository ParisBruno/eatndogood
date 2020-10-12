# frozen_string_literal: true
class Ingredient < ApplicationRecord
  include TranslatedUpcaser
  
  # before_destroy :no_referenced_recipes

  validates :name, presence: true, length: { minimum: 3, maximum: 25 }
  validates :name, :uniqueness => { case_sensitive: false, scope: :app_id }
  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients
  belongs_to :app
  translates :name, fallbacks_for_empty_translations: true
  globalize_accessors :locales => I18n.available_locales, :attributes => [:name]

  before_save :upcase_name

  def no_referenced_recipes
    return if recipes.empty?

    errors.add(:base, "This ingredient is used by #{self.recipes.count} recipes")
    false
  end
end

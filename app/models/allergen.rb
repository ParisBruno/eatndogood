class Allergen < ApplicationRecord
	include TranslatedUpcaser
	
	belongs_to :app
	validates :name, presence: true, length: { minimum: 3, maximum: 25 }
	validates :name, :uniqueness => { case_sensitive: false, scope: :app_id }
	has_and_belongs_to_many :recipes
	translates :name, fallbacks_for_empty_translations: true
	globalize_accessors :locales => I18n.available_locales, :attributes => [:name]
	
	before_save :upcase_name
end

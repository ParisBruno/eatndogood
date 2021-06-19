class Style < ApplicationRecord
	include TranslatedUpcaser

	belongs_to :app
	validates :name, presence: true, length: { minimum: 3, maximum: 25 }
	validates :name, :uniqueness => { case_sensitive: false, scope: :app_id }
	has_and_belongs_to_many :recipes
	has_one_attached :image
	translates :name, fallbacks_for_empty_translations: true
  globalize_accessors :locales => I18n.available_locales, :attributes => [:name]
	before_save :upcase_name

	def self.sizes
    {
      thumb: "300x300"
    }
	end
	
	def sized(image_type, size)
    self.send(image_type).variant(resize: Style.sizes[size]).processed
  end
end

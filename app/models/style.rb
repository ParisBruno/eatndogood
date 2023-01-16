class Style < ApplicationRecord
	include RailsSortable::Model
	include TranslatedUpcaser

  set_sortable :sort
	belongs_to :app
	validates :name, presence: true, length: { minimum: 3, maximum: 25 }
	validates :name, :uniqueness => { case_sensitive: false, scope: :app_id }
	has_and_belongs_to_many :recipes
	has_one_attached :image
	translates :name, :agreement_text, fallbacks_for_empty_translations: true
  globalize_accessors :locales => I18n.available_locales, :attributes => [:name, :agreement_text]
	before_save :upcase_name
	has_many :agreements, dependent: :destroy

	def self.sizes
    {
      thumb: "300x300"
    }
	end
	
	def sized(image_type, size)
    self.send(image_type).variant(resize: Style.sizes[size]).processed rescue nil
  end

  def self.agreement_style
    find(138)
  end
end

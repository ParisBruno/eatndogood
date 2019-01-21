class RecipeImage < ApplicationRecord
	belongs_to :recipe

	has_attached_file :image, styles: { thumb: "300x300>", medium:  "500x500>" }
	validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
	
end

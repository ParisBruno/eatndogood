class RecipeImage < ApplicationRecord
	belongs_to :recipe

	# has_attached_file :image, styles: { thumb: "300x300>", medium:  "500x500>" }
	#validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

	before_save :remove_old_images
	

	private 
	def remove_old_images
		old_images = RecipeImage.where(recipe_id: self.recipe_id, img_type: self.img_type)
		old_images.each do |img|
			img.destroy
		end
	end
end

class RemoveImageOnRecipe < ActiveRecord::Migration[5.1]
  def change
  	remove_attachment :recipes, :image
  end
end

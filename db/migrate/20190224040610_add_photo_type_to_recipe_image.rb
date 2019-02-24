class AddPhotoTypeToRecipeImage < ActiveRecord::Migration[5.1]
  def change
    add_column :recipe_images, :img_type, :string
  end
end

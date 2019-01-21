class AddAttachmentImageToRecipeImages < ActiveRecord::Migration[5.1]
  def self.up
    change_table :recipe_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :recipe_images, :image
  end
end

class AddAttachmentImageToRecipes < ActiveRecord::Migration[5.1]
  def self.up
  	remove_column :recipes, :image
    change_table :recipes do |t|

      t.attachment :image
    end
  end

  def self.down
    remove_attachment :recipes, :image
  end
end

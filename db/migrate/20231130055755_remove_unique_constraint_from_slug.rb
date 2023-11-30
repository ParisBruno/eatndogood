class RemoveUniqueConstraintFromSlug < ActiveRecord::Migration[5.2]
  def change
    remove_index :recipes, :slug
    add_index :recipes, :slug

    remove_index :styles, :slug
    add_index :styles, :slug

    remove_index :ingredients, :slug
    add_index :ingredients, :slug

    remove_index :allergens, :slug
    add_index :allergens, :slug
  end
end

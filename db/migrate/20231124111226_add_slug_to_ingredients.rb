class AddSlugToIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :ingredients, :slug, :string
    add_index :ingredients, :slug, unique: true
  end
end

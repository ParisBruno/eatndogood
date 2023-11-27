class AddSlugToAllergens < ActiveRecord::Migration[5.2]
  def change
    add_column :allergens, :slug, :string
    add_index :allergens, :slug, unique: true
  end
end

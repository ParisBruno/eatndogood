class AddSubcategoryToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_reference :recipes, :subcategory, foreign_key: true
  end
end

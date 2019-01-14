class CreateJoinTableRecipeAllergen < ActiveRecord::Migration[5.1]
  def change
    create_join_table :recipes, :allergens do |t|
       t.index [:recipe_id, :allergen_id]
      # t.index [:allergen_id, :recipe_id]
    end
  end
end

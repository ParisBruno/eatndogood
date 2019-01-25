class CreateJoinTableRecipesStyles < ActiveRecord::Migration[5.1]
  def change
    create_join_table :recipes, :styles do |t|
      t.index [:recipe_id, :style_id]
      # t.index [:style_id, :recipe_id]
    end
  end
end

class AddSortToIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :ingredients, :sort, :integer
  end
end

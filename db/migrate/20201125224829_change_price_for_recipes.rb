class ChangePriceForRecipes < ActiveRecord::Migration[5.2]
  def change
    change_column :recipes, :price, :decimal, precision: 8, scale: 2, default: 0
  end
end

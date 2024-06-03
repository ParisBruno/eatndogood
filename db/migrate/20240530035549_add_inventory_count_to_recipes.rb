class AddInventoryCountToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :inventory_count, :integer
    add_column :recipes, :is_inventory_count, :boolean, default: false
  end
end

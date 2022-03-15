class AddSortToAllergens < ActiveRecord::Migration[5.2]
  def change
    add_column :allergens, :sort, :integer
  end
end

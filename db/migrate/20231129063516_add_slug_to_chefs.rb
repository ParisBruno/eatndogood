class AddSlugToChefs < ActiveRecord::Migration[5.2]
  def change
    add_column :chefs, :slug, :string
    add_index :chefs, :slug
  end
end

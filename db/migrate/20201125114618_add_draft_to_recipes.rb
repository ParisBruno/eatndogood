class AddDraftToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :is_draft, :boolean, default: false
  end
end

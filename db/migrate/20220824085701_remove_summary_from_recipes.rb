class RemoveSummaryFromRecipes < ActiveRecord::Migration[5.2]
  def change
    remove_column :recipes, :summary, :text
  end
end

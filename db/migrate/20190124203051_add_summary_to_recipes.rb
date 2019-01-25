class AddSummaryToRecipes < ActiveRecord::Migration[5.1]
  def change
  	add_column :recipes, :summary, :text
  end
end

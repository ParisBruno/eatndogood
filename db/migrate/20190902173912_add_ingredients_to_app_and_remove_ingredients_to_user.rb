class AddIngredientsToAppAndRemoveIngredientsToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :ingredients, :app, foreign_key: true
    remove_reference :ingredients, :user
  end
end

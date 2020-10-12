class AddAllergensToAppAndRemoveAllergensToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :allergens, :app, foreign_key: true
    remove_reference :allergens, :user
  end
end

class AddEnableReservationToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :enable_reservation, :boolean, default: false
  end
end

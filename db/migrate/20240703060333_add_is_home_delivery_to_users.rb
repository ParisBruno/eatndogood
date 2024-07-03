class AddIsHomeDeliveryToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_home_delivery, :boolean, default: false
  end
end

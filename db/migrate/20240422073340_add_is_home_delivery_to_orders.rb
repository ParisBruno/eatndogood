class AddIsHomeDeliveryToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :is_home_delivery, :boolean, default: false
    add_column :orders, :message, :text
  end
end

class AddTaxAndDeliveryToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :product_tax, :decimal, precision: 5, scale: 2, default: 0
    add_column :users, :delivery_price, :decimal, precision: 5, scale: 2, default: 0
  end
end

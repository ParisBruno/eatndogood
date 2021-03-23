class AddCouponeCodeToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :delivery_price, :decimal, precision: 5, scale: 2, default: 0
    add_column :orders, :tip_value, :decimal, precision: 5, scale: 2, default: 0
    add_column :orders, :total_tax, :decimal, precision: 5, scale: 2, default: 0
    add_column :orders, :coupon_discount, :decimal, precision: 5, scale: 2, default: 0
    add_column :orders, :sub_total, :integer
    add_column :orders, :coupon_code, :string
    add_column :orders, :fundrasing_code, :string
  end
end

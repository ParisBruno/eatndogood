class AddPriceToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :amount, :integer
    add_column :line_items, :sub_total, :integer
    add_column :line_items, :total_tax, :decimal, precision: 5, scale: 2, default: 0
    add_column :line_items, :coupon_discount, :decimal, precision: 5, scale: 2, default: 0
  end
end

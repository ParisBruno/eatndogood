class AddCouponAmountOffToCouponCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :coupon_codes, :coupon_amount_off, :decimal, precision: 5, scale: 2, default: 0
  end
end

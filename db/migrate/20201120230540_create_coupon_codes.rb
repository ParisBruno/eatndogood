class CreateCouponCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :coupon_codes do |t|
      t.string :title
      t.decimal :coupon_percent_off, precision: 5, scale: 2, default: 0
      t.boolean :is_active, default: true
      t.references :chef, null: false, foreign_key: true

      t.timestamps
    end
  end
end

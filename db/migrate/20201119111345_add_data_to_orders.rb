class AddDataToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :amount, :integer
    add_column :orders, :stripe_session_id, :string
    add_column :orders, :stripe_status, :string
    add_column :orders, :stripe_shipping, :jsonb
    add_column :orders, :paypal_token, :string
    add_column :orders, :paypal_status, :string
  end
end

class AddPaymentFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_publishable_key, :string
    add_column :users, :stripe_secret_key, :string
    add_column :users, :selected_payment_methods, :text, array: true, default: ['cash']
  end
end

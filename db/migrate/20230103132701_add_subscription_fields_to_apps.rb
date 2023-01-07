class AddSubscriptionFieldsToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :stripe_customer_id, :string
    add_column :apps, :stripe_subscription_id, :string
  end
end

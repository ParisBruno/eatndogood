class AddIsSubscriptionToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :is_subscription, :boolean, default: false
  end
end

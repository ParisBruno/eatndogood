class AddEnableGiftCardToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :enable_gift_card, :boolean, default: false
  end
end

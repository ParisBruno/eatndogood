class AddActiveToGiftCard < ActiveRecord::Migration[5.2]
  def change
    add_column :gift_cards, :is_active, :boolean, default: false
  end
end

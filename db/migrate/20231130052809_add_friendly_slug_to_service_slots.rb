class AddFriendlySlugToServiceSlots < ActiveRecord::Migration[5.2]
  def change
    add_column :service_slots, :slug, :string
    add_index :service_slots, :slug
  end
end

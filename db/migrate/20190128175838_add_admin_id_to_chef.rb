class AddAdminIdToChef < ActiveRecord::Migration[5.1]
  def change
    add_column :chefs, :admin_id, :integer
  end
end

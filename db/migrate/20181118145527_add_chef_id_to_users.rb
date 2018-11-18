class AddChefIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :chef_id, :integer, index: true
  end
end

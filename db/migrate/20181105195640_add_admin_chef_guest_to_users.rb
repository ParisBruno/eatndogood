class AddAdminChefGuestToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :admin, :boolean
    add_column :users, :chef, :boolean
    add_column :users, :guest, :boolean, default: true
  end
end

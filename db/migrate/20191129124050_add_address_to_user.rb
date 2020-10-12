class AddAddressToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :address_line_1, :string
    add_column :users, :address_line_2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :postal_code, :string
    add_column :users, :country, :string
  end
end

class AddTeamDataForUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :store_address, :string, default: ''
    add_column :users, :phone, :string, default: ''
    add_column :users, :greeting_message, :string, default: ''
  end
end

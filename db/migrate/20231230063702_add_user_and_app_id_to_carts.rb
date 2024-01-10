class AddUserAndAppIdToCarts < ActiveRecord::Migration[5.2]
  def change
    add_reference :carts, :user
    add_reference :carts, :app
  end
end

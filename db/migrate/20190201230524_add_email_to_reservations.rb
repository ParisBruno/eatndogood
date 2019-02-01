class AddEmailToReservations < ActiveRecord::Migration[5.1]
  def change
    add_column :reservations, :email, :string
  end
end

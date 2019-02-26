class AddTypeToReservation < ActiveRecord::Migration[5.1]
  def change
    add_column :reservations, :re_type, :string
  end
end

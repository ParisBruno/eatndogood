class AddReservationsToAppAndRemoveReservationsToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :reservations, :app, foreign_key: true
    remove_reference :reservations, :user
  end
end

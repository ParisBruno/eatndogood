class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.string :full_name
      t.string :phone_number
      t.integer :number_people
      t.date :ci_date
      t.time :ci_time
      t.text :notes
      t.integer :recipe_id
      t.integer :user_id

      t.timestamps
    end
  end
end

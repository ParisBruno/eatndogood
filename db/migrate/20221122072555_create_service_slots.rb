class CreateServiceSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :service_slots do |t|
      t.references :service, foreign_key: true
      t.boolean :booked, default: false
      t.datetime :day
      t.datetime :start_time
      t.datetime :end_time
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :number_of_people
      t.string :phone_number
      t.text :address

      t.timestamps
    end
  end
end

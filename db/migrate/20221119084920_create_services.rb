class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services do |t|
      t.integer :start_day
      t.integer :end_day
      t.time :start_time
      t.time :end_time
      t.integer :customers
      t.text :icon
      t.integer :sort
      t.references :user, foreign_key: true
      t.references :app, foreign_key: true
      t.references :service_type, foreign_key: true

      t.timestamps
    end
  end
end

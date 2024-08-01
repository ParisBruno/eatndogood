class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :deliveries do |t|
      t.text :location
      t.integer :status, default: 0, null: false
      t.text :note
      t.string :image
      t.references :app, foreign_key: true
      t.references :user, foreign_key: true
      t.references :order, foreign_key: true
      t.integer :created_by_user_id, foreign_key: true

      t.timestamps
    end
  end
end

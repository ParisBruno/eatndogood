class CreateGiftCards < ActiveRecord::Migration[5.2]
  def change
    create_table :gift_cards do |t|
      t.string :name
      t.string :purchaser_name
      t.string :purchaser_email
      t.string :client_name
      t.string :client_email
      t.text :description
      t.decimal :price, precision: 8, scale: 2, default: 0
      t.datetime :last_used_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

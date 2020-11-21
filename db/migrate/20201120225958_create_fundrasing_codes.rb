class CreateFundrasingCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :fundrasing_codes do |t|
      t.string :title
      t.boolean :is_active, default: true
      t.references :chef, null: false, foreign_key: true

      t.timestamps
    end
  end
end

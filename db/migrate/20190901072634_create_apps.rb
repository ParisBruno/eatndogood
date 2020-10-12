class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :slug
      t.references :plan, foreign_key: true

      t.timestamps
    end
    add_index :apps, :name, unique: true
    add_index :apps, :slug, unique: true
  end
end

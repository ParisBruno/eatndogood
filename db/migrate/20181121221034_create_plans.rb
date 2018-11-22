class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :title, uniq: true, index: true
      t.integer :chefs_limit
      t.integer :guests_limit
      t.integer :recipes_limit
    end
  end
end

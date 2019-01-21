class CreatePlanCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :plan_categories do |t|
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end

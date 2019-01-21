class AddPlanCategoryIdToPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :plan_category_id, :integer
  end
end

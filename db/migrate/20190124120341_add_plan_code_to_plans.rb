class AddPlanCodeToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :code, :string
  end
end

class AddPlanIdToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :plan, index: true
    add_foreign_key :users, :plans
  end
end

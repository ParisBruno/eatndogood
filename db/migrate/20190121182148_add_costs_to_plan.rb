class AddCostsToPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :yearly_cost, :decimal
    add_column :plans, :cost_per_user, :decimal
    add_column :plans, :no_of_chefs, :bigint
    add_column :plans, :status, :string
    add_column :plans, :guest, :text
  end
end

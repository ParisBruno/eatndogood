class RemovePlanToUser < ActiveRecord::Migration[5.1]
  def change
    remove_reference :users, :plan
  end
end

class RemoveNameIndexFromApps < ActiveRecord::Migration[5.2]
  def change
    remove_index :apps, :name
  end
end

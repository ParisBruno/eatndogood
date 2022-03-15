class AddSortToStyles < ActiveRecord::Migration[5.2]
  def change
    add_column :styles, :sort, :integer
  end
end

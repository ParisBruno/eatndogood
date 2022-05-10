class AddParentTypeToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :parent_type, :string
  end
end

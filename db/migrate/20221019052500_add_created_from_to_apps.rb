class AddCreatedFromToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :created_from, :string
  end
end

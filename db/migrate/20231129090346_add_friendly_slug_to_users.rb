class AddFriendlySlugToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :slug, :string
    add_index :users, :slug
  end
end

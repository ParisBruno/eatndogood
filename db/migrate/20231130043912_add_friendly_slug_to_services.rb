class AddFriendlySlugToServices < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :slug, :string
    add_index :services, :slug
  end
end

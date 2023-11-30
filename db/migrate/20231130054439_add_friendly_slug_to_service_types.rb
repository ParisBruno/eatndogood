class AddFriendlySlugToServiceTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :service_types, :slug, :string
    add_index :service_types, :slug
  end
end

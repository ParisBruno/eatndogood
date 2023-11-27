class AddSlugToStyles < ActiveRecord::Migration[5.2]
  def change
    add_column :styles, :slug, :string
    add_index :styles, :slug, unique: true
  end
end

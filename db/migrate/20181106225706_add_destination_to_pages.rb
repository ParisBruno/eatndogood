class AddDestinationToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :destination, :string
  end
end

class AddAdminNameToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :admin_name, :text
  end
end

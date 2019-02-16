class ChangeDataTypeOfPage < ActiveRecord::Migration[5.1]
  def change
  	change_column :pages, :title, :text
  	change_column :pages, :content, :text
  end
end

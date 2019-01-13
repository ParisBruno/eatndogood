class ChangeChefTable < ActiveRecord::Migration[5.1]
  def up
  	remove_column :chefs, :chefname
  	remove_column :chefs, :email
  	remove_column :chefs, :password_digest
  	add_column :chefs, :user_id, :integer
  	add_column :chefs, :my_bio, :text
  end

  def down

  end
end

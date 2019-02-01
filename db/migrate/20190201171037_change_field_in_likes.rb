class ChangeFieldInLikes < ActiveRecord::Migration[5.1]
  def change
  	rename_column :likes, :chef_id, :user_id
  end
end

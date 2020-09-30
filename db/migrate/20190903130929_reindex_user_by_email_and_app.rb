class ReindexUserByEmailAndApp < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :email
     add_index :users, [:email, :app_id], :unique => true
  end
end

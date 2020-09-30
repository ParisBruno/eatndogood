class AddLikesToAppAndRemoveLikesToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :likes, :app, foreign_key: true
    remove_reference :likes, :user
  end
end

class AddStylesToAppAndRemoveStylesToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :styles, :app, foreign_key: true
    remove_reference :styles, :user
  end
end

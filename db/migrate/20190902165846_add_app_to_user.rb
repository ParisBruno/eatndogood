class AddAppToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :app, foreign_key: true
  end
end

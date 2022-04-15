class ChangeGrettingMessageTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :greeting_message, :text
  end
end

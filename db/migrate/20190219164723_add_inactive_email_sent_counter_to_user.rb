class AddInactiveEmailSentCounterToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email_sent_counter, :integer, default: 0
  end
end

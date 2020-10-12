class AddQuestionsToAppAndRemoveQuestionsToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :questions, :app, foreign_key: true
    remove_reference :questions, :user
  end
end

class RemoveAppRefToQuestions < ActiveRecord::Migration[5.1]
  def change
    remove_reference :questions, :app, foreign_key: true
  end
end

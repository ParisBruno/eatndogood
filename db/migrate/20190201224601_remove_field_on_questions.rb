class RemoveFieldOnQuestions < ActiveRecord::Migration[5.1]
  def change
  	remove_column :questions, :full_name
  	remove_column :questions, :phone_number
  	remove_column :questions, :number_people
  	remove_column :questions, :ci_date
  	remove_column :questions, :ci_time
  	remove_column :questions, :question_type
  end
end

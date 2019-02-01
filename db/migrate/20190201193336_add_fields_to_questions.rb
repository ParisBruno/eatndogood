class AddFieldsToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :full_name, :string
    add_column :questions, :phone_number, :string
    add_column :questions, :number_people, :integer
    add_column :questions, :ci_date, :date
    add_column :questions, :ci_time, :time
    add_column :questions, :question_type, :string
  end
end

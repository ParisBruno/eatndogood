class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.integer :user_id
      t.integer :recipe_id
      t.string :user_type
      t.string :subject
      t.string :email
      t.text :body
      t.timestamps
    end
  end
end

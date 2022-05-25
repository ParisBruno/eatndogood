class CreateAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :agreements do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :guardian_email
      t.string :guardian_first_name
      t.string :guardian_last_name
      t.references :style, foreign_key: true

      t.timestamps
    end
  end
end

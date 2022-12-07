class CreateServiceTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :service_types do |t|
      t.string :name
      t.references :app, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

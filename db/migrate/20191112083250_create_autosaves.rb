class CreateAutosaves < ActiveRecord::Migration[5.2]
  def change
    create_table :autosaves do |t|
      t.string :form
      t.json :payload
      t.references :app

      t.timestamps
    end
  end
end

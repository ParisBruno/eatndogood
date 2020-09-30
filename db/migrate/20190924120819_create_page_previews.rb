class CreatePagePreviews < ActiveRecord::Migration[5.2]
  def change
    create_table :page_previews do |t|
      t.string :name
      t.string :title
      t.text :content
      t.string :destination
      t.references :page, foreign_key: true

      t.timestamps
    end
  end
end

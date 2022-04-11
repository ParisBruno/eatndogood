class AddNoteToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :note, :text
  end
end

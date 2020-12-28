class AddCartToLineItems < ActiveRecord::Migration[5.2]
  def change
    remove_reference :line_items, :recipe, index: true, foreign_key: true
    remove_reference :line_items, :cart, index: true, foreign_key: true
    add_reference :line_items, :gift_card, index: true
    add_reference :line_items, :recipe, index: true
    add_reference :line_items, :cart, index: true
  end
end

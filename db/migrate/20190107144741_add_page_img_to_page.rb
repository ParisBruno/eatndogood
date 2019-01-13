class AddPageImgToPage < ActiveRecord::Migration[5.1]
  def up
     add_attachment :pages, :page_img
   end

   def down
     remove_attachment :pages, :page_img
   end
end

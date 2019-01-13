class AddAttachmentChefAvatarToChefs < ActiveRecord::Migration[5.1]
  def self.up
    change_table :chefs do |t|
      t.attachment :chef_avatar
    end
  end

  def self.down
    remove_attachment :chefs, :chef_avatar
  end
end

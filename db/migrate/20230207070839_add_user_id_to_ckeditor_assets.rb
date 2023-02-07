class AddUserIdToCkeditorAssets < ActiveRecord::Migration[5.2]
  def change
    add_reference :ckeditor_assets, :user, foreign_key: true
  end
end

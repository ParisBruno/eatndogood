class RenameEmailId < ActiveRecord::Migration[5.1]
  def change
  	rename_column :mail_attachments, :email_id, :email_content_id
  end
end

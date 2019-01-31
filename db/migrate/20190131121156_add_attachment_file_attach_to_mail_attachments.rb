class AddAttachmentFileAttachToMailAttachments < ActiveRecord::Migration[5.1]
  def self.up
    change_table :mail_attachments do |t|
      t.attachment :file_attach
    end
  end

  def self.down
    remove_attachment :mail_attachments, :file_attach
  end
end

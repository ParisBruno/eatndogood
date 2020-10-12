class MailAttachment < ApplicationRecord
	belongs_to :email_content

	# has_attached_file :file_attach
	# do_not_validate_attachment_file_type :file_attach
end

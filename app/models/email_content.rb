class EmailContent < ApplicationRecord
	has_many :mail_attachments

	has_one_attached :attacment
end

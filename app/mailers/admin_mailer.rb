# frozen_string_literal: true

class AdminMailer < ApplicationMailer

  def notification_email(chef_name, receiver, from, content, files)
    @receiver = receiver
    @email_body = content
    if !files.nil? && !files.empty?
    	files.each do |file|
    		attachments[file.file_attach_file_name] = File.read(file.file_attach.path)
    	end
    end
    
    mail(to: receiver, from: from,:subject => "Hi! You have message from #{chef_name}")
  end

  def inactive_guests_email(receiver, guests)
    @guests  = guests
    mail(to: receiver.email, subject: 'List of inactive guests')
  end
end

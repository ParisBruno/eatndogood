class UserMailer < ActionMailer::Base
	default :from => "bruno@itoprecipes.com"

	def welcome_email(email,url,email_body)
		@url  = url
		@email_body = email_body
		mail(to: email, subject: 'Welcome to itoprecipes.com')
	end

	def password_email(email,url)
		@url  = url
		mail(to: email, subject: 'ITopRecipes password reset link')
	end

	def reservation_email(from_email, to_email, reservation)
		@reservation = reservation
		mail(to: to_email, from: from_email, subject: "New Reservation")
	end


	def guest_create_email_to_admin(email,guest_info)
		@guest  = guest_info
		mail(to: email, subject: 'Guest registered notification')
	end

	def guest_create_email_to_guest(email)
		mail(to: email, subject: 'Welcome to our Team')
	end

	def buy_gift_card_email(gift_card_id, app_id)
		@app = App.find_by(id: app_id)
		@gift_card = GiftCard.find_by(id: gift_card_id)
		@gift_card.to_active
		emails = [ @gift_card.user.email, @app&.users.where(admin: true).first.email, @gift_card.client_email ].uniq

		mail(to: emails, subject: 'Present Gift Card!')
	end

	def chef_create_email(chef,password,admin,url)
		@chef  = chef
		@password  = password
		@admin  = admin
		@url  = url
		@app_url = @url+'about/'+@admin.chefname+'?admin_id='+@admin.id.to_s
		mail(to: @chef.email, subject: 'itoprecipes.com, Account registered successfully!')
	end

	def recipe_limit_email(chef,limit)
		@chef  = chef
		@limit  = limit
		mail(to: @chef.email, subject: 'itoprecipes.com, Add recipe limit has over!')
	end

	def inactive_notification_email(chef)
		@chef  = chef
		mail(to: @chef.email, subject: 'itoprecipes.com, Notification for not login from 60 days!')
	end

	def sendUserEmailContent(email,url,email_body)
		@url  = url
		@email_body = email_body
		mail(to: email, subject: 'Email alert! itoprecipes.com')
	end

	def message_to_manager_email(params, attachment)
		if attachment
			attachments[attachment[0].original_filename] = { mime_type: attachment[0].content_type, 
																									content: File.read(attachment[0].tempfile.to_path.to_s) }
		end
		@sender_name = params[:sender_name]
		@sender_email = params[:sender_email]
		@recipient_name = params[:recipient_name]
		@content = params[:content]
		@subject = params[:subject].present? ? params[:subject] : "New message from #{@sender_name}"
		mail(to: params[:recipient_email], subject: @subject)
	end
end
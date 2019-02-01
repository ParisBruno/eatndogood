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

	def question_email(from_email, to_email, question)
		@question = question
		mail(to: to_email, from: from_email, subject: "New Reservation")
	end


	def guest_create_email_to_admin(email,guest_info)
		@guest  = guest_info
		mail(to: email, subject: 'Guest registered notification')
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
end
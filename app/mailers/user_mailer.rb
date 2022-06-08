class UserMailer < ActionMailer::Base

  def welcome_email(user,password,current_app)
    @user  = user
    @password = password
    mail(to: user.email, subject: 'Your RockyStepsWay app login credentials!')
    mail(from: current_app.admin_user)
  end

	def password_email(email,url,current_app)
		@url  = url
		mail(to: email, subject: 'RockeyStepsWay password reset link')
		mail(from: current_app.admin_user)
	end

	def reservation_email(from_email, to_email, reservation,current_app)
		@reservation = reservation
		mail(to: to_email, from: from_email, subject: "New Reservation")
		mail(from: current_app.admin_user)
	end


	def guest_create_email_to_admin(email,guest_info,current_app)
		@guest  = guest_info
		mail(to: email, subject: 'Guest registered notification')
		mail(from: current_app.admin_user)
	end

	def guest_create_email_to_guest(email,current_app)
		mail(to: email, subject: 'Welcome to our Team')
		mail(from: current_app.admin_user)
	end

	def buy_gift_card_email(gift_card_id, app_id,current_app)
		@app = App.find_by(id: app_id)
		@gift_card = GiftCard.find_by(id: gift_card_id)
		@gift_card.to_active
		emails = [ @gift_card.user.email, @app&.main_admin.email, @gift_card.client_email ].uniq

		mail(to: emails, subject: 'Present Gift Card!')
		mail(from: current_app.admin_user)
	end

	def chef_create_email(chef,password,admin,url,current_app)
		@chef  = chef
		@password  = password
		@admin  = admin
		@url  = url
		@app_url = @url+'about/'+@admin.chefname+'?admin_id='+@admin.id.to_s
		mail(to: @chef.email, subject: 'itoprecipes.com, Account registered successfully!')
		mail(from: current_app.admin_user)
	end

	def recipe_limit_email(chef,limit,current_app)
		@chef  = chef
		@limit  = limit
		mail(to: @chef.email, subject: 'itoprecipes.com, Add recipe limit has over!')
		mail(from: current_app.admin_user)
	end

	def inactive_notification_email(chef,current_app)
		@chef  = chef
		mail(to: @chef.email, subject: 'itoprecipes.com, Notification for not login from 60 days!')
		mail(from: current_app.admin_user)
	end

	def sendUserEmailContent(email,url,email_body,current_app)
		@url  = url
		@email_body = email_body
		mail(to: email, subject: 'Email alert! itoprecipes.com')
		mail(from: current_app.admin_user)
	end

	def message_to_manager_email(data, filename, content_type, blob_content,current_app)
		if filename && content_type && blob_content
			blob = Base64.decode64(blob_content)
			attachments[filename] = { mime_type: content_type, content: blob }
		end
		@sender_name = data[:sender_name]
		@sender_email = data[:sender_email]
		@recipient_name = data[:recipient_name]
		@content = data[:content]
		@subject = data[:subject].present? ? data[:subject] : "New message from #{@sender_name}"
		mail(to: data[:recipient_email], subject: @subject)
		mail(from: current_app.admin_user)
	end

	def send_receipt_to_client(client_email, order_id, items_styles, admin_email = nil,current_app)
		@admin = User.find_by(email: admin_email) if admin_email
		@items_with_styles = items_styles
		@order = Order.find_by(id: order_id)
		receipt_file = WickedPdf.new.pdf_from_string(
      render_to_string('orders/show.pdf.erb', layout: 'pdf'),
      margin: {
        top: 0, bottom: '2.85cm', left: 0, right: 0
      }
		)
		file_name = "order_#{@order.id}_#{@order.created_at&.strftime('%Y%m%d')}"
		attachments["#{file_name}.pdf"] = receipt_file
		@client_email = client_email
		mail(to: [client_email, admin_email], subject: 'Thank You for Your Order')
		mail(from: current_app.admin_user)
	end

	def error_message_from_user(content,current_app)
		@content = content
		mail(to: "bruno@itoprecipes.com", subject: 'New error message')
		mail(from: current_app.admin_user)
	end
end
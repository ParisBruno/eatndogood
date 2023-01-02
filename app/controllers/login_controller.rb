class LoginController < ApplicationController
	layout 'withoutlogin'

	before_action :logout_current_user, only: %i[fetchapi]
	skip_before_action :set_app
	skip_before_action :configure_permitted_parameters
	skip_before_action :set_header_data
	skip_before_action :check_app_user

	def new
	  return redirect_to recipes_path if current_member.present?

	  @disable_nav = true

	  vars = request.query_parameters
	  @is_guest = (vars[:is_guest].present?) ? vars[:is_guest] : 'n'
	  @identification = (vars[:iden].present?) ? vars[:iden] : 'Admin'
	end

	def create
	  @disable_nav = true

	  @is_guest = (params[:is_guest].present?) ? params[:is_guest] : 'n'

	  if @is_guest == 'yes'
	    guestLogin(params)
	  else
	    chef = Chef.find_by(email: params[:email])

	    if chef
	      pass = params[:password]
	      is_password_valid = chef.check_password(pass)

	      if is_password_valid
	        session[:chef_id] = chef.id
	        session[:user_role] = 'admin'
	        flash[:success] = I18n.t('flash.you_are_logged_in')
	        redirect_to recipes_path
	      else
	        flash.now[:danger] = I18n.t 'flash.your_email_or_password_dont_match'
	        render 'new'
	      end
	    else
	      flash.now[:danger] = I18n.t 'flash.your_email_or_password_dont_match'
	      render 'new'
	    end
	  end
	end

	def destroy
	  @disable_nav = true
	  session[:chef_id] = nil
	  session[:user_role] = nil
	  flash[:success] = I18n.t 'flash.you_have_logged_out'
	  redirect_to app_path(current_app)
	end

	def create_chef (user_id, admin)
		Chef.create({user_id: user_id, admin: admin})
	end

	 #api that is calling from woocommerce for forgot password
	def forgotpasswordwp
	  vars = request.query_parameters
	  email = (vars[:email].present?) ? vars[:email] : ''
	  password = (vars[:password].present?) ? Base64.decode64(vars[:password]) : ''
	  chef = Chef.where(:email => email).first

	  if chef.present?
	    chef.password_digest = chef.convert_password_hash(password)
	    chef.save
	    render :json => {:status=>'success'}
	  else
	    render :json => {:status=>'failed'}
	  end
	end

	#api that is calling from woocommerce for forgot password
	def deleteuserwp
	  vars = request.query_parameters
	  email = (vars[:email].present?) ? vars[:email] : ''

	  user = User.where(:email => email).first

	  if user.present?
	    User.where(:email => email).destroy_all
	    render :json => {:status=>'success'}
	  else
	    render :json => {:status=>'failed'}
	  end
	end

	#api that is calling from woocommerce check user exist in ROR app
	def checkuserinrorapp
	  vars = request.query_parameters
	  email = (vars[:email].present?) ? vars[:email] : ''

	  user = User.where(:email => email).first

	  if user.present?
	    render :json => {:status => 'success', :message => I18n.t('flash.user_already_registered')}
	  else
	    render :json => {:status => 'failed', :message => I18n.t('flash.user_not_registered')}
	  end
	end

	#forgot password action
	def forgot
	  @disable_nav = true
	  vars = request.query_parameters
	  @is_guest = (vars[:is_guest].present?) ? vars[:is_guest] : 'n'
	end

	#forgot password post action
	def forgotpassword
	  @disable_nav = true

	  @is_guest = (params[:is_guest].present?) ? params[:is_guest] : 'n'

	  if @is_guest == 'yes'
	    @guest = Guest.find_by(email: params[:email].downcase)
	  else
	    @guest = Chef.find_by(email: params[:email].downcase)
	  end

	  if @guest.present?
	    root_url = root_url(:only_path => false)
	    email = params[:email]
	    email_encode   = Base64.encode64(email)

	    url = root_url+'changepassword/'+@is_guest+'/'+email_encode
	    # Tell the UserMailer to send a welcome email
	    UserMailer.password_email(email,url, current_app).deliver_now

	    #@user.send_password_reset_email
	    flash[:success] = I18n.t 'flash.email_sent_password_reset_instr'
	    redirect_to root_url
	  else
	    flash[:danger] = I18n.t 'flash.email_address_not_found'
	    render 'forgot'
	  end
	  #redirect_to forgot_url
	end

	 #forgot password action
	def changepassword
	  @disable_nav = true
	  @email = (params[:email].present?) ? Base64.decode64(params[:email]) : ''
	  @is_guest = (params[:is_guest].present?) ? params[:is_guest] : 'n'

	  if @is_guest == 'yes'
	    @guest = Guest.find_by(email: @email)
	  else
	    @guest = Chef.find_by(email: @email)
	  end

	  unless @guest.present?
	    flash[:danger] = I18n.t 'flash.wrong_url_provided'
	    redirect_to root_url
	  end
	end

	#password resets action
	def passwordresets
	  @disable_nav = true
	  id = params[:id]
	  @guest = Guest.find_by(id: id)

	  if params[:guest][:password].empty?
	    flash[:danger] = I18n.t 'flash.password_cant_be_empty'
	    render 'changepassword'
	  elsif params[:guest][:password_confirmation].empty?
	    flash[:danger] = I18n.t 'flash.password_confirm_cant_be_empty'
	    render 'changepassword'
	  elsif params[:guest][:password] != params[:guest][:password_confirmation]
	    flash[:danger] = I18n.t 'flash.password_and_confirm_must_be_same'
	    render 'changepassword'
	  elsif @guest.present?
	    params[:guest][:password] = @guest.convert_password_hash(params[:guest][:password])
	    @guest.update_attributes(user_params)

	    flash[:success] = I18n.t 'flash.password_has_been_reset'
	    redirect_to login_path
	  else
	    render 'changepassword'
	  end
	end

	#password resets action
	def passwordresetsadmin
	  @disable_nav = true
	  id = params[:id]
	  @guest = Chef.find_by(id: id)

	  if params[:chef][:password_digest].empty?
	    flash[:danger] = I18n.t 'flash.password_cant_be_empty'
	    render 'changepassword'
	  elsif params[:chef][:password_confirmation].empty?
	    flash[:danger] = I18n.t 'flash.password_confirm_cant_be_empty'
	    render 'changepassword'
	  elsif params[:chef][:password_digest] != params[:chef][:password_confirmation]
	    flash[:danger] = I18n.t 'flash.password_and_confirm_must_be_same'
	    render 'changepassword'
	  elsif @guest.present?
	     params[:chef][:password_digest] = @guest.convert_password_hash(params[:chef][:password_digest])
	     @guest.update_attributes(admin_params)

	    flash[:success] = I18n.t 'flash.password_has_been_reset'
	    redirect_to login_path
	  else
	    render 'changepassword'
	  end
	end

	def inactivenotification
	  Chef.all.each do |chef|
	    last_login    = chef.last_login
	    current_time  = Time.now

	    if last_login.present?
	      diff = (current_time - last_login) / 86400
	      diff = diff.to_i

	      #send email if inactive from 60 days
	      if diff >= 60
	        UserMailer.inactive_notification_email(chef, current_app).deliver_now
	      end
	    end
	  end

	  render :text => 'yes'
	end

	private

	def guestLogin(params)
	  guest = Guest.find_by(email: params[:email])

	  if guest
	    pass = params[:password]
	    is_password_valid = guest.check_password(pass)

	    if is_password_valid
	      session[:chef_id] = guest.id
	      session[:user_role] = 'guest'
	      flash[:success] = I18n.t('flash.you_are_logged_in')
	      redirect_to recipes_path
	    else
	       flash.now[:danger] = I18n.t 'flash.your_email_or_password_dont_match'
	       redirect_to login_path+'?is_guest=yes', :notice => I18n.t('flash.your_email_or_password_dont_match')
	    end
	  else
	    flash.now[:danger] = I18n.t 'flash.your_email_or_password_dont_match'
	    redirect_to login_path+'?is_guest=yes', :notice => I18n.t('flash.your_email_or_password_dont_match')
	  end
	end

	def user_params
	  params.require(:guest).permit(:password)
	end

	def admin_params
	  params.require(:chef).permit(:password_digest)
	end

	def logout_current_user
		sign_out(current_app_user) if current_app_user
	end
end

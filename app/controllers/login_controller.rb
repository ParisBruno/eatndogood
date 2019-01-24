class LoginController < ApplicationController
	layout 'withoutlogin'

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
	  redirect_to root_path
	end

	#api that is calling from woocommerce
	def fetchapi
	  vars = request.query_parameters
	  email = (vars[:uem].present?) ? Base64.decode64(vars[:uem]) : ''
	  pass =  (vars[:upw].present?) ? Base64.decode64(vars[:upw]) : ''
	  cat_name = (vars[:cat_name].present?) ? Base64.decode64(vars[:cat_name]) : ''
	  prod_name = (vars[:prod_name].present?) ? Base64.decode64(vars[:prod_name]) : ''

	  guest = (vars[:guest].present?) ? Base64.decode64(vars[:guest]) : ''
	  yearly_cost = (vars[:yearly_cost].present?) ? Base64.decode64(vars[:yearly_cost]) : ''
	  cost_per_user = (vars[:cost_per_user].present?) ? Base64.decode64(vars[:cost_per_user]) : ''

	  #call function to create plan and their category
	  if (cat_name.present? && prod_name.present?)
	    plan =createPlanCategory(vars)
	    plan_id = (plan.present?) ? plan.id : ''
	  else
	    plan_id = ''
	  end

	  #code to check if email and password present then create user and do autologin
	  if email.present? && pass.present?
	    user = User.find_by(email: email)

	    #if chef is exist then login
	    if user && user.valid_password?(pass)
	      #call function to assign plan of the user
	      assignPlan(user.id,plan_id) if plan_id.present?

	      session[:chef_id] = user.chef.id
	      session[:user_role] = 'admin'
	      flash[:success] = I18n.t('flash.you_are_logged_in')
	      redirect_to recipes_path
	    else #if chef is not present then create new chef
	      @user = User.create!({email: email, password: pass, plan: plan_id})

	      @chef = Chef.new
		  @chef.user_id = @user.id	     
	      @chef.admin = true

	      if @chef.save!(:validate => false)
	        #call function to assign plan of the user
	        assignPlan(@user.id, plan_id) if plan_id.present?

	        flash[:success] = I18n.t 'flash.your_account_created'
	        session[:chef_id] = @chef.id
	        session[:user_role] = 'admin'
	        redirect_to recipes_path
	      else
	        flash[:danger] = I18n.t 'flash.wrong_credentials'
	        redirect_to root_path
	      end
	    end

	  else
	    #suppose user upgrade plan then pasword is already set
	    chef = User.find_by(email: email)

	    if chef
	      assignPlan(chef.id,plan_id) if plan_id.present?

	      session[:chef_id] = chef.id
	      session[:user_role] = 'admin'
	      flash[:success] = I18n.t('flash.you_are_logged_in')
	      redirect_to recipes_path

	    else
	      flash[:danger] = I18n.t 'flash.invalid_arguments'
	      redirect_to root_path
	    end
	  end #end if to check the user
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

	#api that is calling from woocommerce to update product(Plan) in ROR app
	def updateplaninrorapp
	  vars          = request.query_parameters
	  name          = (vars[:name].present?) ? vars[:name] : ''
	  yearly_cost   = (vars[:yearly_cost].present?) ? vars[:yearly_cost] : ''
	  cost_per_user = (vars[:cost_per_user].present?) ? vars[:cost_per_user] : ''
	  no_of_chefs   = (vars[:no_of_chefs].present?) ? vars[:no_of_chefs] : ''
	  guest         = (vars[:guest].present?) ? vars[:guest] : ''

	  plan = Plan.where('name LIKE ?', "%#{name}%").first

	  if plan.present?
	    plan.name           = (name.blank?) ? plan.name : name
	    plan.yearly_cost    = (yearly_cost.blank?) ? plan.yearly_cost : yearly_cost
	    plan.cost_per_user  = (cost_per_user.blank?) ? plan.cost_per_user : cost_per_user
	    plan.no_of_chefs    = (no_of_chefs.blank?) ? plan.no_of_chefs : no_of_chefs
	    plan.guest          = (guest.blank?) ? plan.guest : guest
	    #plan.save
	    render :json => plan
	  else
	    render :json => {:status => 'failed', :message => I18n.t('flash.plan_not_updated')}
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
	    UserMailer.password_email(email,url).deliver

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
	        UserMailer.inactive_notification_email(chef).deliver
	      end
	    end
	  end

	  render :text => 'yes'
	end

	private

	def createPlanCategory(vars)
	  #vars = request.query_parameters
	  email     = (vars[:uem].present?) ? Base64.decode64(vars[:uem]) : ''
	  pass      = (vars[:upw].present?) ? Base64.decode64(vars[:upw]) : ''
	  cat_name  = (vars[:cat_name].present?) ? Base64.decode64(vars[:cat_name]) : ''
	  prod_name = (vars[:prod_name].present?) ? Base64.decode64(vars[:prod_name]) : ''

	  guest         = (vars[:guest].present?) ? Base64.decode64(vars[:guest]) : ''
	  yearly_cost   = (vars[:yearly_cost].present?) ? Base64.decode64(vars[:yearly_cost]) : ''
	  cost_per_user = (vars[:cost_per_user].present?) ? Base64.decode64(vars[:cost_per_user]) : ''

	  prod_name = prod_name.capitalize if prod_name.present?

	  #check if plan category is present
	  if cat_name.present?
	    cat_name = cat_name.capitalize
	    #code to check plan category
	    planCategory = PlanCategory.find_by(name: cat_name)

	    #if plancategory not present then create new one
	    unless planCategory.present?
	      planCategoryObj = PlanCategory.new
	      planCategoryObj.name    = cat_name
	      planCategoryObj.status  = 'yes'
	      #if save plan category then save plan also
	      if planCategoryObj.save
	        #call function to create plan
	        planObj = createPlan(vars, planCategoryObj)
	        return planObj
	      end # end if to save plan category
	    else # else if plan category exist
	      #if plan category present then update
	      planCategory.name = cat_name
	      planCategory.save

	      #call function to create plan
	      planObj = createPlan(vars, planCategory)
	      return planObj
	    end #end unless
	  end # end if to check plan category is present
	end

	def createPlan(vars, planCategoryObj)
	  #vars = request.query_parameters
	  email     = (vars[:uem].present?) ? Base64.decode64(vars[:uem]) : ''
	  pass      = (vars[:upw].present?) ? Base64.decode64(vars[:upw]) : ''
	  cat_name  = (vars[:cat_name].present?) ? Base64.decode64(vars[:cat_name]) : ''
	  prod_name = (vars[:prod_name].present?) ? Base64.decode64(vars[:prod_name]) : ''

	  guest         = (vars[:guest].present?) ? Base64.decode64(vars[:guest]) : ''
	  yearly_cost   = (vars[:yearly_cost].present?) ? Base64.decode64(vars[:yearly_cost]) : ''
	  cost_per_user = (vars[:cost_per_user].present?) ? Base64.decode64(vars[:cost_per_user]) : ''

	  no_of_chefs = (vars[:chefs].present?) ? Base64.decode64(vars[:chefs]) : ''

	  #check for if plan already exist
	  prod_name = prod_name.capitalize if prod_name.present?

	  planExist = Plan.find_by(title: prod_name)

	  if planExist.present?
	    planExist.name              = prod_name
	    planExist.yearly_cost       = yearly_cost
	    planExist.cost_per_user     = cost_per_user
	    planExist.plan_category_id  = planCategoryObj.id
	    planExist.no_of_chefs       = no_of_chefs
	    planExist.guest             = guest
	    planExist.save

	    return planExist
	  else
	    planObj = Plan.new()
	    planObj.title              = prod_name
	    planObj.status            = 'yes'
	    planObj.plan_category_id  = planCategoryObj.id
	    planObj.yearly_cost       = yearly_cost
	    planObj.cost_per_user     = cost_per_user
	    planObj.no_of_chefs       = no_of_chefs
	    planObj.guest             = guest

	    return planObj if planObj.save
	  end
	end

	def assignPlan(user_id, plan_id)
	  user = User.where("user_id = ?", user_id).first

	  if user.present? && user.plan_id != plan_id
	    #update previous plan
	    user.plan_id = plan_id
	    user.save
	  end
	end

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
end

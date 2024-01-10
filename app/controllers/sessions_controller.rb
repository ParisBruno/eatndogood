class SessionsController < ApplicationController
  
  def new
    
  end
  
  def create
    chef = Chef.find_by(email: params[:session][:email].downcase)
    if chef && chef.authenticate(params[:session][:password])
      session[:chef_id] = chef.id
      cookies.signed[:chef_id] = chef.id
      flash[:success] = t('flash.successfully_logged_in')
      redirect_to chef
    else
      flash.now[:danger] = t('flash.something_wrong')
      render 'new'
    end
  end
  
  def destroy
    session[:chef_id] = nil
    flash[:success] = t('flash.you_have_logged_out')
    redirect_to app_route(app_path(current_app))
  end
  
end

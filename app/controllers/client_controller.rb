class ClientController < ApplicationController
  def show

  end

  private 
  def set_user
  	@user = User.where("dasherize_vanity= ?",params[:id]).first
  end
end

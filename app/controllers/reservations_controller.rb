class ReservationsController < ApplicationController

  def new
  	@email = params[:email] if !params[:email].empty?
  	@user_id = params[:user_id]
  	@recipe_id = params[:recipe_id]
  	@reservation = Reservation.new
  end


  def create
  	@reservation = Reservation.new(reservation_params)

  	respond_to do |format|
  	  if @reservation.save
  	    to_email = @reservation.recipe.chef.admin_user.present? ? @reservation.recipe.chef.admin_user.email : "brunofiuggi@gmail.com"
				# raise @reservation.inspect
				UserMailer.reservation_email(@reservation.email, to_email, @reservation).deliver_now
  	    message = 'Make Reservation successfully.'
        message = 'Sent catering question to chef' if @reservation != "reservation"
  	    format.html { redirect_to app_recipe_path(current_app, @reservation.recipe_id), notice: 'Make Reservation successfully.' }
  	    
  	  else
  	    format.html { render :new }
  	    format.json { render json: @reservation.errors, status: :unprocessable_entity }
  	  end
  	end
  end

  private

  def reservation_params
  	params.require(:reservation).permit(:user_id, :email, :notes, :recipe_id, :full_name, :phone_number,
  	              :number_people, :ci_date, :ci_time, :re_type, :app_id)
  end 


end

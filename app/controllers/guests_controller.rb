class GuestsController < ApplicationController

  def index
    return redirect_to root_path unless current_user.chef?

    @guests = current_user.guests.paginate(page: params[:page], per_page: 5)
  end
end

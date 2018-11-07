class PagesController < ApplicationController
  def index
    @pages = Page.all
  end

  def welcome
    @page = get_page
  end

  def about
    @page = get_page
  end

  def edit
    @page = get_page
  end

  def update
    @page = Page.where(destination: page_params[:destination]).first
    if @page.update(page_params)
      redirect_to "/pages/#{page_params[:destination]}"
    else
      render :edit
    end
  end

  private

  def destination
    Page.get_destination(request.path_info)
  end

  def get_page
    Page.where(destination: destination).first
  end

  def page_params
    params.require(:page).permit(:title, :content, :destination)
  end
end

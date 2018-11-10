class PagesController < ApplicationController
  layout :select_layout_header

  def index
    if params[:set_locale]
      redirect_to about_pages_url(locale: params[:set_locale])
    end
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

  def select_layout_header
    params[:action] == destination ? '_without_header' : 'application'
  end

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

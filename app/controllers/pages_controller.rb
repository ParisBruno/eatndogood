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
    @page = Page.new if @page.nil?
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
    path = request.path_info
    path = "#{path}welcome" if (path.nil? || path.empty? || path == '/')
    Page.get_destination(path)
  end

  def get_page
    Page.where(destination: destination).first
  end

  def page_params
    params.require(:page).permit(:title, :content, :destination, :page_img)
  end
end

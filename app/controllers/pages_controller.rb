class PagesController < ApplicationController
  layout :select_layout_header
  before_action :set_admin_id, only: ['welcome', 'about', 'edit', 'update']
  before_action :guest_email, only: ['welcome', 'about']

  def index
    if params[:set_locale]
      redirect_to about_pages_url(locale: params[:set_locale])
    end
  end

  def welcome
    user = User.find(@admin_id)
    @admin_name = user.full_name if user
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
    @page = get_update_page

    if @page.update(page_params)
      redirect_to "/pages/#{page_params[:destination]}"
    else
      render :edit
    end
  end

  private

  def guest_email
    @guest_email = params[:guest_email]
  end


  def select_layout_header
    params[:action] == destination ? '_without_header' : 'application'
  end

  def destination
    path = request.path_info
    path = "#{path}welcome" if (path.nil? || path.empty? || path == '/')
    path = "/welcome" if path == '/live'
    Page.get_destination(path)
  end

  def get_page
    if @admin_id.present?
      Page.where(destination: destination, user_id: @admin_id).first
    else
      Page.where(destination: destination).first
    end
  end

  def get_update_page
    Page.find params[:id]
  end

  def page_params
    params.require(:page).permit(:title, :content, :destination, :page_img, :admin_name)
  end
end

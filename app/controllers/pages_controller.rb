class PagesController < ApplicationController
  layout :select_layout_header
  before_action :guest_email, only: ['welcome', 'about']
  before_action :require_logged_in, only: %i[edit update]

  before_action :set_locale, only: [:about, :welcome]

  def index
    if params[:set_locale]
      redirect_to about_pages_url(locale: params[:set_locale])
    end
  end

  # def welcome
  #   user = User.find(@admin_id)
  #   @admin_name = user.full_name if user
  #   @page = get_page
  # end

  def create
    @page = Page.new(page_params.merge(app_id: current_app.id, destination: 'about'))

    if @page.save
      delete_draft(@page)        
      redirect_to about_app_pages_url(current_app)
    else
      render :edit
    end 
  end

  def welcome
    @locale = cookies[:locale][0..1].to_sym if cookies[:locale].present?
    @page = get_page
  end

  def about
    @page = get_page
  end

  def edit
    @page = get_page
    @page = Page.new if @page.nil?
  end

  def preview
    page = Page.find(params[:id])
    redirect_to app_path(current_app) if page.nil?
    @page = page.page_preview
    redirect_to app_path(current_app) if @page.nil?
  end

  def update
    @page = get_update_page
    # raise page_params.inspect
    if preview?
      @page_preview = @page.page_preview
      if @page.page_preview.nil?
        @page_preview = @page.build_page_preview(page_params)
        @page_preview.save
      else
        @page_preview.update(page_params)
      end
      url = preview_app_page_path(current_app, @page)
      render js: "var win = window.open('#{url}', '_blank'); win.focus();"
    else
      if @page.update(page_params)
        # redirect_to "/pages/#{page_params[:destination]}"
        # redirect_to app_page_path(current_app, @page.destination)
        delete_draft(@page)
        # render :js => "window.location = '#{app_page_path(current_app, @page.destination)}'"
        render :js => "var win = window.open('#{app_page_path(current_app, @page.destination)}', '_blank'); win.focus();"
      else
        render :edit
        # render :js => "window.location = '/jobs/index'"
      end 
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
    if @app.present?
      Page.where(destination: destination, app_id: @app.id).first
    else
      Page.where(destination: destination).first
    end
  end

  def get_update_page
    Page.find params[:id]
  end

  def page_params
    permitted = Page.globalize_attribute_names + [:destination, :page_img, :admin_name, :landscape_page_img]
    params.require(:page).permit(*permitted)
  end

  def preview?
    params[:preview].present?
  end

  def delete_draft(page)
    url = "/#{current_app.slug}/pages/#{page.id}"
    as = current_app.autosaves.where(form: url).first
    if as
      as.destroy
    end
  end
end

class StylesController < ApplicationController
  before_action :set_apps
  before_action :set_style, only: [:show, :edit, :update, :destroy]
  before_action :require_admin_or_chef, except: [:show, :index, :table]
  before_action :require_logged_in, only: [:new, :create, :edit, :update, :destroy]

  # GET /styles
  # GET /styles.json
  def index
    @styles = Style.where(app_id: @app_ids)
  end

  # GET /styles/1
  # GET /styles/1.json
  def show
    if @style.nil?
      flash[:success] = t('common.not_found', name: 'Category')
      redirect_to table_app_styles_path(current_app)
    else
      redirect_to app_recipe_path(current_app, 489) if @style.id == 138 && ((current_app_user.present? && !current_app_user.admin? && current_app_user.agreement.nil?) || (current_app_user.nil? && cookies[:agreement].nil?))
      users = current_app.created_from == "fundraise" ? User.where(app_id: [current_app.id, App.fundraise.id]) : current_app.users
      recipes = @style.recipes.joins(chef: [user: :app]).where(chefs: {id: users.includes(:chef_info).pluck("chefs.id")})
      recipes = recipes.where(is_draft: false) unless current_app_user&.admin?
      @recipes = recipes.paginate(page: params[:page], per_page: 5)
    end
  end

  # GET /styles/new
  def new
    @style = Style.new
  end

  # GET /styles/1/edit
  def edit
  end

  # POST /styles
  # POST /styles.json
  def create
    @style = Style.new(style_params)
    @style.app_id = current_app.id
    respond_to do |format|
      if @style.save
        format.html { redirect_to table_app_styles_path(current_app), notice: t('common.successfully_created', name: 'Category')}
        format.json { render :show, status: :created, location: @style }
      else
        format.html { render :new }
        format.json { render json: @style.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /styles/1
  # PATCH/PUT /styles/1.json
  def update
    respond_to do |format|
      if @style.update(style_params)
        if !params[:style][:agreement_text_en].nil?
          path = new_app_agreement_path(@current_app)
          notice = t('common.successfully_updated', name: 'Agreement')
        else
          path = app_styles_path(current_app)
          notice = t('common.successfully_updated', name: 'Category')
        end
        format.html { redirect_to path, notice: notice }
        format.json { render :show, status: :ok, location: @style }
      else
        if !params[:style][:agreement_text_en].nil?
          @failed_agreement_text = true
          format.html { render 'pages/agreement' }
        else
          format.html { render :edit }
        end
        format.json { render json: @style.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /styles/1
  # DELETE /styles/1.json
  def destroy
    unless @style.recipes.count > 0
      @style.destroy
      respond_to do |format|
        format.html { redirect_to app_styles_path(current_app), notice: t('common.successfully_destroyed', name: 'Category')}
        format.json { head :no_content }
      end
    else
      redirect_to app_styles_path(current_app), notice: t('common.has_recipe_not_destroyed', name: 'Category')
    end
  end

  def table
    @styles = Style.where(app_id: @app_ids).order(:sort)
  end

  def update_positions
    params[:elements].each do |ele|
      style = Style.find(ele[1][:id])
      style.update(sort: ele[0])
    end
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_style
      @style = Style.where(id: params[:id], app_id: @app_ids).last
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def style_params
      params.require(:style).permit(*Style.globalize_attribute_names + [:image])
    end
end

class StylesController < ApplicationController
  before_action :set_style, only: [:show, :edit, :update, :destroy]
  before_action :require_admin_or_chef, except: [:show, :index]

  # GET /styles
  # GET /styles.json
  def index
    @styles = Style.where(app_id: current_app.id)
  end

  # GET /styles/1
  # GET /styles/1.json
  def show
    @recipes = @style.recipes.paginate(page: params[:page], per_page: 5)
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
        format.html { redirect_to app_styles_path(current_app), notice: 'Style was successfully created.' }
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
        format.html { redirect_to app_styles_path(current_app), notice: 'Style was successfully updated.' }
        format.json { render :show, status: :ok, location: @style }
      else
        format.html { render :edit }
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
        format.html { redirect_to app_styles_path(current_app), notice: 'Style was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to app_styles_path(current_app), notice: 'Style has recipes and cannot be destroyed'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_style
      @style = Style.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def style_params
      params.require(:style).permit(*Style.globalize_attribute_names)
    end
end

class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @email = params[:email] if !params[:email].empty?
    @user_id = params[:user_id]
    @recipe_id = params[:recipe_id]
    @make_reservation = params[:make_reservation]
    @question = Question.new
    @question.subject = "Make Reservation" if @make_reservation
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        
        ActionMailer::Base.mail(from: "bruno@itoprecipes.com", to: @question.email, subject: @question.subject, body: @question.body).deliver_later
        
        if params[:question][:question_type] == 'reservation'
          format.html { redirect_to app_recipe_path(current_app, @question.recipe_id), notice: 'Make Reservation successfully.' }
        else
          format.html { redirect_to app_recipe_path(current_app, @question.recipe_id), notice: 'Question was successfully created.' }
          format.json { render :show, status: :created, location: @question }
        end
        
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to [current_app, @question], notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to app_questions_path(current_app), notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:user_id, :email, :subject, :body, :recipe_id)
    end
end

class MessagesController < ApplicationController
  before_action :require_user
  skip_before_action :verify_authenticity_token, :set_app, only: %i[error_message]
  
  def create
    @message = Message.new(message_params)
    @message.chef = current_chef
    if @message.save
      ActionCable.server.broadcast 'chatroom_channel', message: render_message(@message),
                                                        chef: @message.chef.chefname
    else
      render 'chatrooms/show'
    end
  end

  def managers
    @recipient = User.find_by(id: params[:recipient_id])
    redirect_to app_managers_path(current_app), notice: t('chefs.not_defined') unless @recipient
  end

  def send_email
    if params[:message][:attachment]
      @filename = params[:message][:attachment][0].original_filename
      @content_type = params[:message][:attachment][0].content_type
      file_content = File.read(params[:message][:attachment][0].tempfile.to_path.to_s)
      @blob = Base64.encode64(file_content)
    end
    UserMailer.message_to_manager_email(email_message_params, @filename, @content_type, @blob, current_app).deliver_now
    redirect_to app_managers_path(current_app), notice: t('chefs.success_email')
  end
  
  def error_message
    UserMailer.error_message_from_user(params[:message], current_app).deliver_now
    redirect_to app_recipes_path(current_app)
  end

  private

  def email_message_params
    params.require(:message).permit(:sender_name, :sender_email, :recipient_name, :recipient_email, 
                                    :subject, :content)
  end
  
  def message_params
    params.require(:message).permit(:content)
  end
  
  def render_message(message)
    render(partial: 'message', locals: { message: message } )
  end
end
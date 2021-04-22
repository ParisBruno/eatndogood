class MessagesController < ApplicationController
  before_action :require_user
  
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
      @blob = File.read(params[:message][:attachment][0].tempfile.to_path.to_s)
    end
    UserMailer.message_to_manager_email(email_message_params, @filename, @content_type, @blob).deliver_later
    redirect_to app_managers_path(current_app), notice: t('chefs.success_email')
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
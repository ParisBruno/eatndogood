class OrderMailer < ActionMailer::Base

  def receipt_email(order_id,current_app)
    @order = Order.find(order_id)
    mail(to: @order.email, subject: 'Order Receipt')
    mail(from: current_app.admin_user)
  end
end

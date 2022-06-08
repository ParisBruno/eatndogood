class OrderMailer < ActionMailer::Base

  def receipt_email(order_id, current_app)
    @order = Order.find(order_id)
    mail(from: current_app.main_admin&.email, to: @order.email, subject: 'Order Receipt')
  end
end

class OrderMailer < ActionMailer::Base
  default :from => "bruno@itoprecipes.com"

  def receipt_email(order_id)
    @order = Order.find(order_id)
    mail(to: @order.email, subject: 'Order Receipt')
  end
end

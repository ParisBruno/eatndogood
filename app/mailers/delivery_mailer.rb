class DeliveryMailer < ApplicationMailer

  def send_driver_email(delivery_ids)
    @deliveries = Delivery.where(id: delivery_ids)
    first_delivery = @deliveries.first
    @driver = first_delivery.user
    @current_app = first_delivery.app

    mail(
      from: @current_app.main_admin&.email,
      to: @driver.email,
      subject: 'New Delivery Assigned'
    )
  end

  def send_order_delivered_email(delivery)
    @delivery = delivery
    @order_email = delivery.order.email
    @current_app = delivery.app

    mail(
      from: @current_app.main_admin&.email,
      to: @order_email,
      subject: 'Delivered Successfully'
    )
  end
end

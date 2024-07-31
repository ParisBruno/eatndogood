module DeliveriesHelper
  def delivery_status
    statuses = Delivery.statuses.map{|status| [status[0].humanize, status[0]]}
    (@sessioned_user.admin? || @sessioned_user.manager?) ? statuses : statuses.reject { |status| status[0] == 'Not assigned' }
  end
end

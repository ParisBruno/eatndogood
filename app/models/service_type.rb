class ServiceType < ApplicationRecord
  belongs_to :app
  belongs_to :user
  has_many :services, dependent: :destroy
  extend FriendlyId
  friendly_id :name, use: :slugged, use: [:slugged, :scoped], scope: :user

  def available_services
    services = self.services.where.not(start_day: nil)
    booked_days_number = ServiceSlot.where(service_id: services.pluck(:id), booked: true).map{|x| [x.day.to_date.wday, x.service_id]}
    booked_days = booked_days_number.map{|num| [week_days[num[0]], num[1]]}
    avail_days = services.map{|x| week_days_with_service(x.id)[x.start_day..x.end_day]}.flatten(1)
    booked_days.map{|day| avail_days.delete(day)}
    avail_days.map{|x| x[1]}.uniq
  end

  def available_time_slots(day, people)
    # Get all services according to customers count
    filtered_services = self.services.where.not(start_day: nil).where("customers Is NULL OR customers >= ?", people)

    # Get services according to booking day
    week_day = day.to_date.wday.zero? ? 6 : day.to_date.wday-1
    services = filtered_services.select{|x| week_day.between?(x.start_day, x.end_day)}

    # Get booked slots
    booked_timings = ServiceSlot.where(service_id: services.pluck(:id), booked: true).map{|x| [x.start_time, x.end_time, x.day.to_date, x.service_id.to_s, x.service.customers]}
    booked_slots = get_slots(booked_timings, day.to_date)

    # Get all slots
    avail_timings = []
    services.each do |service|
      avail_timings << [service.start_time, service.end_time, day.to_date, service.id.to_s, service.customers]
    end
    avail_slots = get_slots(avail_timings, day.to_date)

    # Get available slots
    booked_data = booked_slots.map{|x| [x[5], x[4]]}
    booked_data.each do |data|
      avail_slots.each do |slot|
        avail_slots.delete(slot) if data[0] == slot[5] && data[1] == slot[4]
      end
    end
    avail_slots.present? ? avail_slots.map{|slot| [slot[0], slot[1], slot[4]]} : []
  end

  private
  def week_days
    [['Monday', 0], ['Tuesday', 1], ['Wednesday', 2], ['Thursday', 3], ['Friday', 4], ['Saturday', 5], ['Sunday', 6]]
  end

  def week_days_with_service(service_id)
    [
      [['Monday', 0], service_id],
      [['Tuesday', 1], service_id],
      [['Wednesday', 2], service_id],
      [['Thursday', 3], service_id],
      [['Friday', 4], service_id],
      [['Saturday', 5], service_id],
      [['Sunday', 6], service_id]
    ]
  end

  def get_slots(timings, day)
    slots = []
    timings.each do |slot|
      date = Time.now
      week_day = date.wday
      if week_day == day.wday
        service = Service.find(slot[3])
        if service.end_time.strftime( "%H%M%S%N" ) < date.strftime( "%H%M%S%N" )
          date = date.next_day()
        end
      end
      week_day = date.wday
      while day.wday != week_day do
        date = date.next_day()
        week_day = if date.wday.zero?
                     day.wday.zero? ? 0 : 6
                   else
                     date.wday
                   end
      end
      slots << [slot[0].strftime("%l:%M %p"), slot[1]&.strftime("%l:%M %p"), date.strftime("%d/%m/%y"), slot.last, slot[3], slot[2]]
    end
    slots
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end

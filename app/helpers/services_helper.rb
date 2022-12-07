module ServicesHelper
  def available_days(service)
    week_days[service.start_day..service.end_day]
  end

  def available_timings(service)
    ["#{service.start_time.strftime("%H:%M %p")} - #{service.end_time.strftime("%H:%M %p")}"]
  end

  def avail_services(ids)
    Service.where(id: ids)
  end
end

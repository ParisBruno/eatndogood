class ServiceSlot < ApplicationRecord
  belongs_to :service
  after_save :save_date

  def save_date
    schedule_start_time = self.day.change(hour: self.start_time.hour, min: self.start_time.min, sec: self.start_time.sec)
    schedule_end_time = self.day.change(hour: self.end_time.hour, min: self.end_time.min, sec: self.end_time.sec)
    self.update_columns(start_time: schedule_start_time, end_time: schedule_end_time)
  end
end

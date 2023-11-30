class ServiceSlot < ApplicationRecord
  belongs_to :service
  after_save :save_date
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :scoped], scope: :service

  def slug_candidates
    [
      :service_type_name
    ]
  end

  def service_type_name
    service.service_type.name.parameterize
  end

  def save_date
    schedule_start_time = self.day.change(hour: self.start_time.hour, min: self.start_time.min, sec: self.start_time.sec)
    schedule_end_time = self.day.change(hour: self.service.end_time.hour, min: self.service.end_time.min, sec: self.service.end_time.sec)
    self.update_columns(start_time: schedule_start_time, end_time: schedule_end_time)
  end

  private
  def should_generate_new_friendly_id?
    slug.blank? || service.service_type.name_changed?
  end
end

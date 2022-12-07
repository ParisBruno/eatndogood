class Service < ApplicationRecord
  include RailsSortable::Model
  belongs_to :user
  belongs_to :app
  set_sortable :sort
  belongs_to :service_type
  has_many :service_slots, dependent: :destroy
  validates :icon, presence: true
  validates :start_day, presence: true, if: -> { end_day.present? || end_time.present? || start_time.present? }
  validates :end_day, presence: true, if: -> { start_day.present? || end_time.present? || start_time.present? }
  validates :start_time, presence: true, if: -> { end_time.present? || end_day.present? || start_day.present? }
  validates :end_time, presence: true, if: -> { start_time.present? || end_day.present? || start_day.present? }
  validate :end_date_after_start_date, if: -> { end_day.present? || start_day.present? || end_time.present? || start_time.present? }

  def booking_time
    "#{self.booking_start_at.strftime("%-d/%-m/%y %H:%M %p")} to #{self.booking_end_at.strftime("%-d/%-m/%y %H:%M %p")}"
  end

  def square?
    self.customers.between?(1, 3)
  end

  def circle?
    self.customers.between?(4, 6)
  end

  def rectangle?
    self.customers >= 7
  end

  def border_class
    if self.service_slots.where(booked: true).present?
     "green-border"
    elsif self.start_day.present?
     "blue-border"
    else
      ""
    end
  end

  def image_name
    if self.square?
      "square.jpg"
    elsif self.circle?
      "circle.jpg"
    else
      "rec.jpg"
    end
  end

  private
  def end_date_after_start_date
    if self.start_day.present? && self.end_day.present? && self.start_day > self.end_day
      errors.add(:end_day, "must be after the start day")
    end
    if self.start_time.present? && self.end_time.present? && self.start_time> self.end_time
      errors.add(:end_time, "must be after the start time")
    end
  end
end

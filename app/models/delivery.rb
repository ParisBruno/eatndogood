class Delivery < ApplicationRecord
  belongs_to :app
  belongs_to :order
  belongs_to :user, foreign_key: :user_id, optional: true
  belongs_to :created_by_user, class_name: 'User', foreign_key: :created_by_user_id, optional: true
  has_one_attached :image
  validate :user_must_be_present_if_assigned

  enum status: ["not_assigned", "assigned", "delivered", "canceled"]

  after_save :send_mail_to_driver, if: -> { self.saved_change_to_status? && self.assigned? }

  def self.sizes
    {
      thumb: "300x300"
    }
  end

  def sized(image_type, size)
    self.send(image_type).variant(resize: Delivery.sizes[size]).processed rescue nil
  end

  def send_mail_to_driver
    DeliveryMailer.send_driver_email(self.id).deliver_now
  end

  private

  def user_must_be_present_if_assigned
    if !self.not_assigned? && user_id.blank?
      errors.add(:user_id, "must be selected if the delivery is assigned")
    elsif self.not_assigned? && !user_id.blank?
      errors.add(:status, "must be assigned if the user is present")
    end
  end
end

# frozen_string_literal: true
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  belongs_to :host_chef, class_name: 'User', foreign_key: 'chef_id', optional: true
  belongs_to :plan, optional: true
  has_many :guests, class_name: 'User', foreign_key: 'chef_id'

  validates :plan, presence: true, if: :admin?

  scope :inactive_guests, -> { where('guest = true AND last_sign_in_at > ?', Date.today - 60.days) }

  def full_name
    [first_name, last_name].join(' ')
  end
end

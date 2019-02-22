
# frozen_string_literal: true
class User < ApplicationRecord
  extend FriendlyId

  friendly_id :full_name, use: :slugged
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  #belongs_to :host_chef, class_name: 'User', foreign_key: 'chef_id', optional: true
  belongs_to :plan, optional: true
  has_many :guests, class_name: 'User', foreign_key: 'user_id'
  has_many :chefs, class_name: 'Chef', foreign_key: 'admin_id'
  has_one :chef_info, class_name: 'Chef', foreign_key: 'user_id' , inverse_of: :user, dependent: :destroy
  belongs_to :guest_admin_user, class_name: 'User', foreign_key: 'user_id', optional: true

  has_many :likes, dependent: :destroy
  accepts_nested_attributes_for :chef_info, allow_destroy: true
  has_many :reservations, dependent: :destroy
  validates_uniqueness_of :slug

  validates :plan, presence: true, if: :admin?

  validate :limit_guests, on: :create
  
  scope :inactive_guests, -> { where('guest = true AND last_sign_in_at > ? AND email_sent_counter < 3', Date.today - 60.days) }

  after_create :create_pages
  before_create :set_guest_admin

  def full_name
    [!first_name.nil? ? first_name.capitalize : first_name, !last_name.nil? ? last_name.capitalize : last_name].join(' ')
  end

  def limit_guests
    if self.guest?
      admin = User.find self.user_id
      current_guests = User.where(guest: true, user_id: admin.id).count
      if !admin.plan.guests_limit.nil? && (current_guests >= admin.plan.guests_limit)
        errors.add(:user_id, "Cannot signup to #{admin.full_name} app as guest. Because this user account has reached guests limitation.")
      end
    end
  end

  private 

  def create_pages
    if self.admin
      Page.find_or_create_by(name: "Welcome", title: "Welcome To", content: ["Welcome To", self.full_name, "iTopRecipes App"].join("<br/>"), destination: "welcome", user_id: self.id, admin_name: self.full_name)
      Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", user_id: self.id, admin_name: self.full_name)
    end
  end

  def set_guest_admin
    #self.user_id = params[:user][:admin_id] if self.guest? 
  end

end

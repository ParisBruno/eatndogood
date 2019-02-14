
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
  has_many :chefs, class_name: 'User', foreign_key: 'chef_id'
  has_one :chef_info, class_name: 'Chef', foreign_key: 'user_id' , inverse_of: :user, dependent: :destroy
  has_many :likes, dependent: :destroy
  accepts_nested_attributes_for :chef_info, allow_destroy: true
  has_many :reservations, dependent: :destroy
  validates_uniqueness_of :slug

  validates :plan, presence: true, if: :admin?
  
  scope :inactive_guests, -> { where('guest = true AND last_sign_in_at > ?', Date.today - 60.days) }

  after_create :create_pages

  def full_name
    [first_name, last_name].join(' ')
  end

  private 

  def create_pages
    if self.admin
      Page.find_or_create_by(name: "Welcome", title: "Welcome To", content: "My.iTopRecipes App", destination: "welcome", user_id: self.id)
      Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", user_id: self.id)
    end
  end

end

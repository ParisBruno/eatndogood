
# frozen_string_literal: true
class User < ApplicationRecord
  include UserValidation::Validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, authentication_keys: [:email, :app_id], reset_password_keys: [:email, :app_id]

  #belongs_to :host_chef, class_name: 'User', foreign_key: 'chef_id', optional: true
  # belongs_to :guest_admin_user, class_name: 'User', foreign_key: 'user_id', optional: true
  
  belongs_to :app

  has_one :agreement
  has_one :chef_info, class_name: 'Chef', foreign_key: 'user_id' , inverse_of: :user, dependent: :destroy
  has_many :orders #, dependent: :destroy

  has_many :staff, class_name: 'User', foreign_key: 'manager_id'
  belongs_to :team_manager, class_name: 'User', foreign_key: 'manager_id', optional: true

  accepts_nested_attributes_for :chef_info, allow_destroy: true
  accepts_nested_attributes_for :app

  validates :first_name, presence: true
  # validates :first_name, :last_name, presence: true
  # validates :city, :state, :postal_code, :country, presence: true, on: :create, if: Proc.new {|u| u.guest == true}
  validates :city, presence: true, on: :update, unless: Proc.new {|u| u.city_was.nil?}
  validates :state, presence: true, on: :update, unless: Proc.new {|u| u.state_was.nil? }
  validates :postal_code, presence: true, on: :update, unless: Proc.new {|u| u.postal_code_was.nil? }
  validates :country, presence: true, on: :update, unless: Proc.new {|u| u.country_was.nil? }
  validates :product_tax, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :delivery_price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  validate :limit_guests, on: :create
  validate :check_managers_count
  after_create :send_guest_email_to_admin
  
  scope :inactive_guests, -> { where('guest = true AND last_sign_in_at > ? AND email_sent_counter < 3', Date.today - 60.days) }
  scope :guests, -> { where(guest: true)}
  scope :managers, -> { where(manager: true) }

  # before_create :set_guest_admin
  before_save :downcase_slug

  def downcase_slug
    unless app.nil? && app.slug.nil?
      app.slug = app.slug.gsub(' ', '_').downcase 
      app.save
    end
  end

  def full_name
    [first_name, last_name].join(' ').strip.titleize
  end

  def limit_guests
    if self.guest?
      # admin = User.find self.user_id # hummmm
      # find app
      app = App.find(self.app_id)
      current_guests = app.guests.count
      if !app.plan.guests_limit.nil? && (current_guests >= app.plan.guests_limit)
        errors.add(:user_id, "Cannot signup to #{app.app_name} app as guest. Because this user account has reached guests limitation.")
      end
    end
  end

  def send_guest_email_to_admin
    if self.guest?
      @admin = self.app.main_admin
      UserMailer.guest_create_email_to_admin(@admin.email, self, self.app).deliver_later if @admin
      UserMailer.guest_create_email_to_guest(self.email, self.app).deliver_later if @admin
    end
  end

  def team_member?
    (admin? || manager? || chef?) ? true : false
  end

  def self.find_for_authentication(warden_conditions)
    where(email: warden_conditions[:email], app_id: warden_conditions[:app_id]).first
  end

  private

  # def create_pages
  #   if self.admin
  #     Page.find_or_create_by(name: "Welcome", title: "Welcome To", content: ["Welcome To", self.full_name, "iTopRecipes App"].join("<br/>"), destination: "welcome", user_id: self.id, admin_name: self.full_name)
  #     Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", user_id: self.id, admin_name: self.full_name)
  #   end
  # end

  def set_guest_admin
    #self.user_id = params[:user][:admin_id] if self.guest? 
  end

  def check_managers_count
    managers = app&.users&.where(manager: true)
    if (new_record? && manager?) || (manager? && managers.exclude?(self))
      errors.add(:manager, "- you can't create more than 4 managers") if managers.count >= 4
    end
  end
end

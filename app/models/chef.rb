# frozen_string_literal: true
class Chef < ApplicationRecord
  #before_save { self.email = email.downcase }
  #validates :first, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  has_many :recipes
  #has_secure_password
  #validates :password, presence: true, length: { minimum: 5 }, allow_nil: true
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy
  #has_many :likes, dependent: :destroy
  belongs_to :user, class_name: 'User', foreign_key: :user_id, dependent: :destroy
  #validates :user, presence: true
  #belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'
  # belongs_to :admin_user, class_name: 'User', foreign_key: :admin_id

  # has_attached_file :chef_avatar, styles: { thumb: "300x250>" }
  # validates_attachment_content_type :chef_avatar, content_type: /\Aimage\/.*\z/
  #accepts_nested_attributes_for :user 

  has_one_attached :chef_avatar
  validates :chef_avatar, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}

  before_destroy :move_recipes_to_admin

  translates :my_bio, fallbacks_for_empty_translations: true
  globalize_accessors locales: I18n.available_locales, attributes: [:my_bio]

  
  def admin_user
    self.user.app.main_admin
  end

  def self.sizes
    {
      thumb: "300x250"
    }
  end

  def sized(size)
    self.chef_avatar.variant(resize: Chef.sizes[size]).processed
  end
  
  private
  def move_recipes_to_admin
    self.recipes.each do |recipe|
      recipe.chef_id = !self.admin_user.nil? ? self.admin_user.chef_info.id : User.where(admin: true).first.chef_info.id
      recipe.save
    end
  end

end

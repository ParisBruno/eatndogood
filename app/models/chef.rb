# frozen_string_literal: true
class Chef < ApplicationRecord
  #before_save { self.email = email.downcase }
  #validates :first, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  has_many :recipes, dependent: :destroy
  #has_secure_password
  #validates :password, presence: true, length: { minimum: 5 }, allow_nil: true
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :likes, dependent: :destroy
  belongs_to :user
  validates :user, presence: true

  has_attached_file :chef_avatar, styles: { thumb: "300x250>" }
  validates_attachment_content_type :chef_avatar, content_type: /\Aimage\/.*\z/
  accepts_nested_attributes_for :user 

end

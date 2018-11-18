class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  belongs_to :host_chef, class_name: 'User', foreign_key: 'chef_id', optional: true
  has_many :guests, class_name: 'User', foreign_key: 'chef_id'
end

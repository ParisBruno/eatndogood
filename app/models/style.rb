class Style < ApplicationRecord
	belongs_to :user,:foreign_key => "user_id"
	validates :name, presence: true, length: { minimum: 3, maximum: 25 }
	#validates_uniqueness_of :name
	has_and_belongs_to_many :recipes
end

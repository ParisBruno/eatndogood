class Question < ApplicationRecord
	belongs_to :user
	belongs_to :recipe
	validates_presence_of :full_name, :body, :subject, :phone_number, :email, :number_people, :ci_date, :ci_time
end

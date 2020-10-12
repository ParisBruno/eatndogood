class Reservation < ApplicationRecord

	belongs_to :recipe
	belongs_to :app

	validates_presence_of :full_name, :notes, :phone_number, :email, :number_people, :ci_date, :ci_time
end

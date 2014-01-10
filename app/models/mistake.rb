class Mistake < ActiveRecord::Base

	belongs_to :test
	belongs_to :hint

	validates_presence_of :wrong_output

end

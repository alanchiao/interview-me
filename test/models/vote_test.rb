require 'test_helper'

class VoteTest < ActiveSupport::TestCase
	# Test that vote correctly returns whether the correct value given that it is an upvote or not
	def test_Value
		Vote.all.each do |vote|
			if vote.value == 1
				assert vote.upvote
			else
				assert_not vote.upvote
			end
		end
	end

end

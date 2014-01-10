require 'test_helper'

class ProblemTest < ActiveSupport::TestCase
	def test_isCodeProblem
		assert_not problems(:design1).is_code_problem?
		assert problems(:code1).is_code_problem?
	end

	# Assert that the design question correctly has 2 comments
	# Coding questions should not have any comments
	def test_getComments
		assert_equal(3, problems(:design1).get_comments.size)
		assert_equal(0, problems(:code1).get_comments.size)
    end

    def test_bestComment
    	assert_equal(2, problems(:design1).best_comment.id)
    end
end

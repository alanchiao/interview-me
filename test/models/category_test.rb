require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def test_GroupProblems
	categories(:category1).group_problems_by_difficulty.each do |c|
  		if(c[0]==1)
  			assert_equal(1, c[1].size)
  			assert c[1].include? problems(:design1)
  		elsif(c[0]==2)
  			assert_equal(2, c[1].size)
  			assert c[1].include? problems(:code2)
  			assert c[1].include? problems(:code3)
  		end
  	end
  end

  def test_getAllMappings
  	c = Category.get_all_mappings
  	assert_equal(2, c.size)
  	assert c.include? categories(:category1).name
  	assert c.include? categories(:category2).name
  end
end

class Category < ActiveRecord::Base

	has_many :problems

	# Returns hash with key as the name of the category and the value as the category id.
	def Category.get_all_mappings
		categories = Category.all
		return Hash[categories.collect {|c| [c.name, c.id]}]
	end

	# Returns hash with key as the difficulty of the problem group and the value as the problem.
	def group_problems_by_difficulty
        return self.problems.group_by{ |problem| problem.difficulty }.sort
    end

end

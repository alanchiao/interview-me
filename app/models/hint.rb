class Hint < ActiveRecord::Base

	belongs_to :problem
	has_many :mistakes

	validates_presence_of :content

	#Saves a list of hints and links them to the appropriate problem.
	def Hint.save_hints(problem, hints)
		hints.each do |hint|
			Hint.create(code_problem_id: problem.id, content: hint)
		end
		return problem.hints
	end
end

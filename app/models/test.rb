class Test < ActiveRecord::Base

	belongs_to :code_problem
	has_many :mistakes

	validates_presence_of :input, :correct_output

	accepts_nested_attributes_for :mistakes

	#Saves a hash of tests and links them to the appropriate problem.
	#[[test1input, test1correctoutput],[]]
	def Test.save_tests(problem, tests)
		tests.each do |test|
			saved_test = Test.create(code_problem_id: problem.id, input: test[0], correct_output: test[1])
			test[2].each do |mistake|
				Mistake.create(test_id: saved_test.id, wrong_output: mistake[1], hint_id: mistake[0])
			end
		end
		return problem.tests
	end
end

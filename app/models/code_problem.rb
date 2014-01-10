class CodeProblem < Problem

	has_many :tests
	has_many :hints

	accepts_nested_attributes_for :tests, :allow_destroy => true
	accepts_nested_attributes_for :hints

end
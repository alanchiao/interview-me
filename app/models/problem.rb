class Problem < ActiveRecord::Base

    belongs_to :category
	belongs_to :author, class_name: "User", foreign_key: "author_id"
	has_many :attempts

	validates_presence_of :type, :title, :question, :category, :difficulty, :solution
    validates :difficulty, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3}

	# Return true if this problem is of type code problem
	def is_code_problem?
        return self.type == "CodeProblem"
	end

    # Return true if this problem is of type design problem
    def is_design_problem?
        return self.type == "DesignProblem"
    end

    # Get problem comments sorted in reverse chronological order (most recently created first)
    def get_comments
        return Comment.where(design_problem_id: self.id).sort_by! { |x| x.created_at }.sort! { |a,b| b.created_at <=> a.created_at }
    end

    # Return comment with highest points value for problem
    # Chooses first if multiple comments share highest number of points
    def best_comment
        return self.comments.order('points DESC').first
    end

    # Organize comments for Handlebars template
    def get_comments_pretty(current_user)
        if !self.comments.empty?
            top_comment = self.best_comment.get_pretty(current_user)
        end
        comments = self.get_comments.keep_if { |c| c.id != top_comment[:id]}
        comments = comments.map { |c| c.get_pretty(current_user) }
        return { :comments => comments, :top_comment => top_comment }
    end

    # Get all necessary information (test cases, hints, incorrect outputs) to test code problems
    def get_all_tests_info
        info = {}

        # A map of hint.id to the hint object
        info[:hints] = {}
        self.hints.each do |hint|
            info[:hints][hint.id] = hint
        end

        # A mapping of mistake.id to hint.id
        info[:hintmap] = {}

        # A list of testcases, each of which contains the testcase itself and a list of mistakes
        # associated with the testcase
        info[:testcases] = []
        testcases = self.tests
        testcases.each do |testcase|
            t = {}
            t[:testcase] = testcase

            t[:mistakes] = testcase.mistakes
            testcase.mistakes.each do |mistake|
                # Each testcase has its own mistakes, which have unique ids
                # Associate each of these ids with a hint
                info[:hintmap][mistake.id] = mistake.hint.id
            end

            info[:testcases] << t
        end

        return info
    end
end

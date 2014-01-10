class Attempt < ActiveRecord::Base

	belongs_to :user
	belongs_to :problem

    # Updates user solution attempt at a problem if the user has already worked on the problem
    # else creates an association between the user's work and the problem.
    def Attempt.autosave(user_id, problem_id, text)
        attempt = Problem.find_by(id: problem_id).attempts.find_by(user_id: user_id)
        if !attempt.blank?
            attempt.solution = text
            attempt.save
        else
            Attempt.create(user_id: user_id, problem_id: problem_id, solution: text)
        end
    end

end

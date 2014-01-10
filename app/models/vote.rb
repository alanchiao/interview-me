class Vote < ActiveRecord::Base

    belongs_to :user
    belongs_to :comment

    # Return 1 if this vote is an upvote, and -1 if it is a downvote
    def value
        return self.upvote ? 1 : -1
    end

end

class Comment < ActiveRecord::Base

    include Rails.application.routes.url_helpers

    has_many :votes
	belongs_to :author, class_name: "User", foreign_key: "author_id"
	belongs_to :design_problem

    validates :content, length: {minimum: 1}

    # Return username of comment author
    def get_author_username
        return User.find_by(id: self.author_id).username
    end

    # Updates points to sum of upvotes and downvotes for comment
    def update_points
        self.points = self.votes.to_a.sum { |v| v.value }
    end

    # If user had voted on comment before, destroy the existing vote
    # Create vote if one had not previously existed or if the user
    # switched vote type (upvote --> downvote) or (downvote --> upvote)
    # Associate comment with vote and update comment points
    def cast_vote(user_id, value)
        vote = self.votes.find_by(user_id: user_id)
        is_upvote = (value == 1)

        if !vote.blank?
            vote.destroy
        end

        if vote.blank? or (vote.upvote ^ is_upvote)
            new_vote = Vote.new
            new_vote.user_id = user_id
            new_vote.upvote = is_upvote
            self.votes << new_vote
        end

        self.update_points
        self.save
    end

    # Get if user voted on this comment
    # value -> 1 if querying for upvote, -1 for downvote
    def get_user_vote(user_id, value)
        vote = self.votes.find_by(user_id: user_id)
        if(vote && vote.value == value)
            return "active"
        else
            return ""
        end
    end

    # Format comment attribute for Handlebars template
    def get_pretty(user)
        pretty = {}
        pretty[:id] = self.id
        pretty[:author] = self.get_author_username
        pretty[:author_url] = user_url(self.author, only_path: true)
        pretty[:time] = self.created_at.localtime.strftime('%I:%M %p on %m/%d/%y')
        pretty[:content] = self.content
        pretty[:points] = self.points.to_s + " " + "point".pluralize(self.points.abs)
        if user
            pretty[:signed_in] = true
            pretty[:upvote_class] = self.get_user_vote(user.id, 1)
            pretty[:downvote_class] = self.get_user_vote(user.id, -1)
        end
        return pretty
    end

end

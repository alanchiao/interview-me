class CommentsController < ApplicationController

    before_action :require_login, only: [:vote]

    # Receives AJAX request to case an upvote or downvote on a comment
    # Sends call to update display of comment to reflect vote cast
    def vote
        @comment = Comment.find_by(id: params[:id])
        @comment.cast_vote(current_user.id, params['value'].to_i)
        @comments = @comment.design_problem.get_comments_pretty(current_user)
        respond_to do |format|
            format.js
        end
    end
end
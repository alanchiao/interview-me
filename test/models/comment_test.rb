require 'test_helper'

class CommentTest < ActiveSupport::TestCase
    def test_getAuthorUsername
        assert_equal("user1", comments(:comment1).get_author_username)
        assert_equal("user1", comments(:comment2).get_author_username)
        assert_equal("user2", comments(:comment3).get_author_username)
    end

    # Assert points before and after updating comment
    def test_updatePoints
        # Comment 1
        assert_equal(0, comments(:comment1).points)
        comments(:comment1).update_points
        assert_equal(-1, comments(:comment1).points)
        # Comment 2, correctly sums votes to get this comment's points
        assert_equal(3, comments(:comment2).points)
        comments(:comment2).update_points
        assert_equal(1, comments(:comment2).points)
        # Comment 3
        assert_equal(0, comments(:comment3).points)
        comments(:comment3).update_points
        assert_equal(2, comments(:comment3).points)
    end

    def test_getUserVote
        assert_equal("active", comments(:comment3).get_user_vote(1, 1))
        assert_equal("", comments(:comment3).get_user_vote(1, -1))
        assert_equal("", comments(:comment1).get_user_vote(3, 1))
        assert_equal("active", comments(:comment1).get_user_vote(3, -1))
    end

    def test_castVote
        comments(:comment1).update_points
        assert_equal(-1, comments(:comment1).points)
        comments(:comment1).cast_vote(1, 1) #user1 add upvote
        assert_equal(0, comments(:comment1).points)

        comments(:comment1).cast_vote(1, 1) #user1 tries to upvote again
        assert_equal(0, comments(:comment1).points)

        comments(:comment1).cast_vote(1, -1) #user1 switches to downvote
        assert_equal(-1, comments(:comment1).points)

        comments(:comment1).cast_vote(2, -1) #user2 also downvotes
        assert_equal(-2, comments(:comment1).points)

        comments(:comment1).cast_vote(1, 1) #user1 switches back to upvote
        assert_equal(-1, comments(:comment1).points)
    end
end

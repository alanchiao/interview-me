require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_isContentCreator
    assert_not users(:user1).is_content_creator?
    assert users(:user2).is_content_creator?
    assert_not users(:user3).is_content_creator?
    assert_not users(:user4).is_content_creator?
  end

  def test_isAdmin
    assert users(:user1).is_admin?
    assert_not users(:user2).is_admin?
    assert_not users(:user3).is_admin?
    assert users(:user4).is_admin?
  end

  def test_makeContentCreator
    users(:user1).make_content_creator
    assert users(:user1).is_content_creator?
    assert users(:user2).is_content_creator?
    assert_not users(:user3).is_content_creator?
    assert_not users(:user4).is_content_creator?
  end

  def test_makeAdmin
    users(:user2).make_admin
    assert users(:user1).is_admin?
    assert users(:user2).is_admin?
    assert_not users(:user3).is_admin?
    assert users(:user4).is_admin?
  end

  def test_getContentCreators
    cc = User.get_content_creators
    cc.each do |user|
        assert user.is_content_creator?
    end
  end

  def test_getAdmins
    admin = User.get_admins
    admin.each do |user|
        assert user.is_admin?
    end
  end
end

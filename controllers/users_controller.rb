
require_relative '../models/users.rb'

class UsersController
  def create_item(params)
    user = Users.new(params)
    user.save
  end

  def find_users_by_id(id)
    Users.find_by_id(id)
  end

  def find_users_by_username(username)
    Users.find_by_username(username)
  end

  def find_all_users
    Users.find_all
  end

  def find_users_with_posts_by_id(id)
    user = Users.find_by_id(id)
    user.posts = Posts.find_by_user_id(user.id)
    user
  end
end

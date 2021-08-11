
require_relative '../models/posts.rb'

class PostsController
  def create_post(params)
    post = Posts.new(params)
    post.save
  end
end

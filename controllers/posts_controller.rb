
require_relative '../models/posts.rb'
require_relative '../controllers/hashtags_controller.rb'
require_relative '../utils/strings.rb'

class PostsController
  def create_post(params)
    post = Posts.new(params)
    id = post.save
    if id
      hashtags = find_hashtag(post.content)
      hashtags.each do |hashtag|
        HashtagsController.create(hashtag)
      end
      return id
    end
    false
  end

  def find_by_id(id)
    Posts.find_by_id(id)
  end

  def find_by_hashtag(hashtag)
    Posts.find_by_hashtag(hashtag)
  end

  def find_by_user_id(user_id)
    Posts.find_by_user_id(user_id)
  end

  def find_all
    Posts.find_all
  end
end

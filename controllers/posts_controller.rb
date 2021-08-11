
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
end

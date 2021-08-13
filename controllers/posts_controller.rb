
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

  def find_with_comments_by_id(id)
    post = Posts.find_by_id(id)
    post.comments = Comments.find_by_post_id(id) if not post.nil?
    post
  end

  def find_by_id(id)
    Posts.find_by_id(id)
  end

  def find_by_hashtag(hashtag, is_last_24 = false)
    return Posts.find_by_hashtag_last_hours(hashtag) if is_last_24
    Posts.find_by_hashtag(hashtag)
  end

  def find_by_user_id(user_id)
    Posts.find_by_user_id(user_id)
  end

  def find_all
    Posts.find_all
  end

  def delete_post(id)
    post = find_by_id(id)
    time_now = Time.now
    time_diff = time_now - post.created_at
    if time_diff.to_i < (24 * 60 * 60)
      find_hashtag(post.content).each do |hashtag|
        HashtagsController.decrement_counter(hashtag)
      end
    end
    Posts.remove_by_id(id)
  end
end

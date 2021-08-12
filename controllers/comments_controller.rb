
require_relative '../models/comments.rb'
require_relative '../controllers/hashtags_controller.rb'
require_relative '../utils/strings.rb'

class CommentsController
  def create_comment(params)
    comment = Comments.new(params)
    id = comment.save
    if id
      hashtags = find_hashtag(comment.content)
      hashtags.each do |hashtag|
        HashtagsController.create(hashtag)
      end
      return id
    end
    false
  end

  def find_by_id(id)
    Comments.find_by_id(id)
  end

  def find_by_post_id(post_id)
    Comments.find_by_post_id(post_id)
  end

  def find_by_hashtag(hashtag)
    Comments.find_by_hashtag(hashtag)
  end

  def find_all
    Comments.find_all
  end
end
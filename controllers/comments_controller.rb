
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
end
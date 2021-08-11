
require_relative '../models/hashtags.rb'

class HashtagsController
  def create(content)
    hashtag = Hashtags.find_by_content(content)

    if hashtag.nil?
      Hashtags.new({ :content => content }).save
    else
      time_now = Time.now
      time_diff = time_now - hashtag.updated_at
      time_diff.to_i > (24 * 60 * 60) ? hashtag.reset_counter : hashtag.add_counter
    end
  end

  def decrement_counter(content)
    Hashtags.new({ :content => content }).min_counter
  end
end

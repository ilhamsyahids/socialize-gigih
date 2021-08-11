
require_relative '../models/hashtags.rb'

class HashtagsController
  def create(content)
    Hashtags.new({ :content => content }).save
  end
end

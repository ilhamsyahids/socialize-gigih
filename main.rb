require 'sinatra'

require_relative 'routes/users_routes.rb'
require_relative 'routes/posts_routes.rb'
require_relative 'routes/comments_routes.rb'
require_relative 'routes/hashtags_routes.rb'

require_relative 'utils/response_handler.rb'

before do
  content_type :json
end

get '/' do
  {
    message: 'Welcome Home!'
  }.to_json
end

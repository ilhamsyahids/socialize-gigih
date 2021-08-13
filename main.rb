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

# Get static assets
get '/assets/:type/:filename' do
  type = params[:type]
  filename = params[:filename]
  if type == 'mp4'
    content_type "video/mp4"
  elsif ['jpg', 'jpeg'].include? type
    content_type "image/jpeg"
  elsif ['png', 'gif'].include? type
    content_type "image/#{type}"
  else
    content_type "application/octet-stream"
  end
  File.read(File.join('assets', "#{type}/#{filename}"))
end

# Get all list of files belong to type
get '/files/:type' do
  list = Dir.glob("./assets/#{params[:type]}/*.*").map{|f| f.split('/').last}
  response_generator(status, nil, { files: list })
end

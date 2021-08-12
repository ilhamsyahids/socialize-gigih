require 'sinatra'

require_relative 'routes/users_routes.rb'
require_relative 'routes/posts_routes.rb'

require_relative 'utils/response_handler.rb'

before do
  if ['PUT', 'POST', 'DELETE'].include? request.request_method
    request.body.rewind
    @request_payload = JSON.parse(request.body.read)
    @request_payload.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil}
  end
  content_type :json
end

get '/' do
  {
    message: 'Welcome Home!'
  }.to_json
end

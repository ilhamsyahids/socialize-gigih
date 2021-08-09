require 'sinatra'
require 'sinatra/reloader'

before do
  content_type :json
end

get '/' do
  {
    message: 'Welcome Home!'
  }.to_json
end

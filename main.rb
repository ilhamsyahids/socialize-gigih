require 'sinatra'

require_relative 'controllers/users_controller.rb'

require_relative 'utils/response_handler.rb'

$users_controller = UsersController.new

before do
  content_type :json
end

get '/' do
  {
    message: 'Welcome Home!'
  }.to_json
end

get '/users/:id' do
  user = $users_controller.find_users_with_posts_by_id(params[:id])
  if user.nil?
    status 404
    message = 'User not found'
    return response_generator(status, message)
  end
  user = Users
    .convert_model_to_json(user)
    .merge(Posts.convert_models_to_json(user.posts))
  response_generator(status, message, user)
end

get '/users/id/:id' do
  user = $users_controller.find_users_by_id(params[:id])
  if user.nil?
    status 404
    message = 'User not found'
    return response_generator(status, message)
  end
  user = Users
    .convert_model_to_json(user)
  response_generator(status, message, user)
end

get '/users/username/:username' do
  user = $users_controller.find_users_by_username(params[:username])
  if user.nil?
    status 404
    message = 'User not found'
    return response_generator(status, message)
  end
  user = Users
    .convert_model_to_json(user)
  response_generator(status, message, user)
end

get '/users' do
  users = Users.find_all
  response_generator(status, nil, Users.convert_models_to_json(users))
end

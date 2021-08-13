require 'sinatra'

require_relative '../controllers/users_controller.rb'

require_relative '../utils/response_handler.rb'

$users_controller = UsersController.new

# Users
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

post '/users' do
  begin
    options = {}
    raise "Email required" if params[:email].nil?
    raise "Username required" if params[:username].nil?
    id = $users_controller.create_item(params)
    if id
      status 201
      message = 'User created'
      options[:id] = id
    else
      raise "Bad request"
    end
  rescue Mysql2::Error => exception
    if exception.message.start_with?('Duplicate entry')
      status 409
      if exception.message.include?('email')
        message = 'Email already exists'
      elsif exception.message.include?('username')
        message = 'Username already exists'
      else
        message = 'User already exists'
      end
    end
  rescue => exception
    status 400
    message = exception.message || 'Bad request'
  else
    puts exception
    puts exception.message
  ensure
    return response_generator(status, message, options)
  end
end

put '/users/:id' do
  begin
    raise "Bad request id" if params[:id].nil? || params[:id].to_i < 1

    raise "Email required" if params[:email].nil?
    raise "Username required" if params[:username].nil?

    raise 'User not found' if $users_controller.find_users_by_id(params[:id]).nil?

    if $users_controller.edit_user(params.merge(:id => params[:id].to_i))
      message = 'User successfully updated'
    else
      raise
    end
  rescue Mysql2::Error => exception
    if exception.message.start_with?('Duplicate entry')
      status 409
      if exception.message.include?('email')
        message = 'Email already exists'
      elsif exception.message.include?('username')
        message = 'Username already exists'
      else
        message = 'User already exists'
      end
    end
  rescue => exception
    status 400
    message = exception.message || 'Bad request'
  else
    puts exception
    puts exception.message
  ensure
    return response_generator(status, message)
  end
end

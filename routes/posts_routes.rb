require 'sinatra'

require_relative '../controllers/posts_controller.rb'

require_relative '../utils/response_handler.rb'

$posts_controller = PostsController.new

# Posts
get '/posts/:id' do
  post = $posts_controller.find_with_comments_by_id(params[:id])
  if post.nil?
    status 404
    message = 'Post not found'
    return response_generator(status, message)
  end
  post = Posts
    .convert_model_to_json(post)
    .merge(Comments.convert_models_to_json(post.comments))
  return response_generator(status, message, post)
end

get '/posts/id/:id' do
  post = $posts_controller.find_by_id(params[:id])
  if post.nil?
    status 404
    message = 'Post not found'
    return response_generator(status, message)
  end
  post = Posts
    .convert_model_to_json(post)
  response_generator(status, message, post)
end

get '/posts/user_id/:id' do
  posts = $posts_controller.find_by_user_id(params[:id])
  response_generator(status, nil, Posts.convert_models_to_json(posts))
end

get '/posts/hashtag/:hashtag' do
  posts = $posts_controller.find_by_hashtag(params[:hashtag])
  response_generator(status, nil, Posts.convert_models_to_json(posts))
end

get '/posts' do
  posts = Posts.find_all
  response_generator(status, nil, Posts.convert_models_to_json(posts))
end

post '/posts' do
  begin
    options = {}
    raise "User id required" if @request_payload[:user_id].nil?
    raise "Content required" if @request_payload[:content].nil?
    raise "Content more than 1000 characters" if @request_payload[:content].length > 1000
    id = $posts_controller.create_post(@request_payload)
    if id
      status 201
      message = 'Post created'
      options[:id] = id
    else
      raise "Bad request"
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

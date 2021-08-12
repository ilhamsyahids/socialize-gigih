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

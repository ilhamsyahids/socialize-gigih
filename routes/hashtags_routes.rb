require 'sinatra'

require_relative '../models/hashtags.rb'

require_relative '../controllers/posts_controller.rb'
require_relative '../controllers/comments_controller.rb'

require_relative '../utils/response_handler.rb'

$posts_controller = PostsController.new
$comments_controller = CommentsController.new

# Hashtags
get '/hashtags/trending' do
  response_generator(status, nil, Hashtags.convert_models_to_json(Hashtags.trending))
end

get '/hashtags/content/:content' do
  response_generator(status, nil, Hashtags.convert_model_to_json(Hashtags.find_by_content('#' + params[:content])))
end

get '/hashtags/post/:content' do
  response_generator(status, nil, Posts.convert_models_to_json($posts_controller.find_by_hashtag('#' + params[:content])))
end

get '/hashtags/comment/:content' do
  response_generator(status, nil, Comments.convert_models_to_json($comments_controller.find_by_hashtag('#' + params[:content])))
end

get '/hashtags/all/:content' do
  posts = Posts.convert_models_to_json($posts_controller.find_by_hashtag(params[:content]))
  comments = Comments.convert_models_to_json($comments_controller.find_by_hashtag(params[:content]))
  response_generator(status, nil, posts.merge(comments))
end

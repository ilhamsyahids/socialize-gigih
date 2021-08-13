require 'sinatra'

require_relative '../controllers/comments_controller.rb'

require_relative '../utils/files.rb'
require_relative '../utils/response_handler.rb'

$comments_controller = CommentsController.new

# Comments
get '/comments/id/:id' do
  comment = $comments_controller.find_by_id(params[:id])
  if comment.nil?
    status 404
    message = 'Comment not found'
    return response_generator(status, message)
  end
  response_generator(status, message, Comments.convert_model_to_json(comment))
end

get '/comments/hashtag/:hashtag' do
  comments = $comments_controller.find_by_hashtag(params[:hashtag])
  response_generator(status, nil, Comments.convert_models_to_json(comments))
end

get '/comments/post_id/:id' do
  comments = $comments_controller.find_by_post_id(params[:id])
  response_generator(status, nil, Comments.convert_models_to_json(comments))
end

get '/comments' do
  comments = $comments_controller.find_all
  response_generator(status, nil, Comments.convert_models_to_json(comments))
end

post '/comments' do
  begin
    options = {}
    raise "Post id required" if params[:post_id].nil?
    raise "User id required" if params[:user_id].nil?
    raise "Content required" if params[:content].nil?
    raise "Content more than 1000 characters" if params[:content].length > 1000
    if params[:file]
      saved = save_to_server(params[:file])
      params[:attachment_name] = saved.first
      params[:attachment] = saved.last
    end
    id = $comments_controller.create_comment(params)
    if id
      status 201
      message = 'Comment created'
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


require_relative '../db/db_connector.rb'

class Posts
  attr_accessor :id, :user_id, :content, :created_at, :url

  def initialize(params = {})
    @id = params[:id]
    @user_id = params[:user_id]
    @content = params[:content]
    @created_at = params[:created_at]
    @url = params[:url]
  end

  def valid_url?
    return true if @url.nil? || @url.empty?

    regex = "((http|https)://)(www.)?"
    regex += "[a-zA-Z0-9@:%._\\+~#?&//=]"
    regex += "{2,256}\\.[a-z]"
    regex += "{2,6}\\b([-a-zA-Z0-9@:%"
    regex += "._\\+~#?&//=]*)";

    return false if @url.match(regex).nil?
    true
  end

  def valid_content?
    return false if @content.nil? || @content.empty? || @content.length > 1000
    true
  end

  def valid_user?
    return false if @user_id.nil? || @user_id.to_i < 1
    true
  end

  def valid_id?
    return false if @id.nil? || @id.to_i < 1
    true
  end

  def valid?
    return false unless valid_content?
    return false unless valid_url?
    true
  end
end
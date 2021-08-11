
require_relative '../db/db_connector.rb'

class Comments
  attr_accessor :id, :comment, :user_id, :created_at, :updated_at

  def initialize(params = {})
    @id = params[:id]
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    @content = params[:content]
    @created_at = params[:created_at]
    @attachment = params[:attachment]
  end

  def valid_content?
    return false if @content.nil? || @content.empty? || @content.length > 1000
    true
  end

  def valid_post?
    return false if @post_id.nil? || @post_id.to_i < 1
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
    return false unless valid_post?
    return false unless valid_user?
    return false unless valid_id?
    true
  end
end
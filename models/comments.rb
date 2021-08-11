
require_relative '../db/db_connector.rb'

class Comments
  attr_accessor :id, :content, :post_id, :user_id, :created_at, :updated_at, :attachment, :attachment_name

  def initialize(params = {})
    @id = params[:id]
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    @content = params[:content]
    @created_at = params[:created_at]
    @attachment = params[:attachment]
    @attachment_name = params[:attachment_name]
  end

  def save
    return false unless valid?

    client = create_db_client
    client.query("INSERT INTO comments (user_id, post_id, content, attachment, attachment_name) VALUES (#{user_id}, #{post_id}, '#{content}', '#{attachment}', '#{attachment_name}')")
    true
  end

  def update
    return false unless valid?
    return false unless valid_id?

    client = create_db_client
    client.query("UPDATE comments SET content = '#{content}', attachment = '#{attachment}', attachment_name = '#{attachment_name}', updated_at = NOW() WHERE id = #{id}")
    true
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

  def valid_attachment?
    return true if @attachment.nil?
    return false if @attachment.length > 254
    return true if @attachment_name.nil?
    return false if @attachment_name.length > 254
    true
  end

  def valid?
    return false unless valid_content?
    return false unless valid_post?
    return false unless valid_user?
    return false unless valid_attachment?
    true
  end
end
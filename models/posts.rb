
require_relative '../db/db_connector.rb'

class Posts
  attr_accessor :id, :user_id, :content, :created_at, :updated_at, :attachment, :attachment_name, :comments

  def initialize(params = {})
    @id = params[:id]
    @user_id = params[:user_id]
    @content = params[:content]
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
    @attachment = params[:attachment]
    @attachment_name = params[:attachment_name]
    @comments = []
  end

  def save
    return false unless valid?

    client = create_db_client
    client.query("INSERT INTO posts (user_id, content, attachment, attachment_name) VALUES (#{user_id}, '#{content}', '#{attachment}', '#{attachment_name}')")
    client.last_id
  end

  def update
    return false unless valid?
    return false unless valid_id?

    client = create_db_client
    client.query("UPDATE posts SET content = '#{@content}', attachment = '#{attachment}', attachment_name = '#{attachment_name}', updated_at = NOW() WHERE id = #{@id}")
    true
  end

  def delete
    return false unless valid_id?

    client = create_db_client
    client.query("DELETE FROM posts WHERE id = #{@id}")
    true
  end

  def self.remove_by_id(id)
    Posts.new({ id: id }).delete
    true
  end

  def add_comment(params)
    params[:post_id] = @id
    Comments.new(params).save
  end

  def self.find_all
    client = create_db_client
    result = client.query("SELECT * FROM posts")
    convert_sql_result_to_array(result)
  end

  def self.find_by_id(id)
    client = create_db_client
    result = client.query("SELECT * FROM posts WHERE id = #{id}")
    convert_sql_result_to_array(result)[0]
  end

  def self.find_by_user_id(user_id)
    client = create_db_client
    result = client.query("SELECT * FROM posts WHERE user_id = #{user_id}")
    convert_sql_result_to_array(result)
  end

  def self.find_by_hashtag(hashtag)
    client = create_db_client
    result = client.query("SELECT * FROM posts WHERE content LIKE '%#{hashtag}%'")
    convert_sql_result_to_array(result)
  end

  def self.convert_sql_result_to_array(result)
    data = []
    result.each do |row|
      data << Posts.new({
        content: row['content'],
        attachment: row['attachment'],
        attachment_name: row['attachment_name'],
        updated_at: row['updated_at'],
        created_at: row['created_at'],
        user_id: row['user_id'],
        id: row['id']
      })
    end if !result.nil? && result.size > 0
    data
  end

  def valid_attachment?
    return true if @attachment.nil?
    return false if @attachment.length > 254
    return true if @attachment_name.nil?
    return false if @attachment_name.length > 254
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
    return false unless valid_user?
    return false unless valid_content?
    return false unless valid_attachment?
    true
  end
end
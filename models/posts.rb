
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

  def save
    return false unless valid?

    client = create_db_client
    client.query("INSERT INTO posts (user_id, content, url) VALUES (#{@user_id}, '#{@content}', '#{@url}')")
    true
  end

  def update
    return false unless valid?

    client = create_db_client
    client.query("UPDATE posts SET content = '#{@content}', url = '#{@url}' WHERE id = #{@id}")
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
    convert_sql_result_to_array(result)[0]
  end

  def self.find_by_hashtag(hashtag)
    client = create_db_client
    result = client.query("SELECT * FROM posts WHERE content LIKE '%#{hashtag}%'")
    convert_sql_result_to_array(result)[0]
  end

  def self.convert_sql_result_to_array(result)
    data = []
    result.each do |row|
      data << Posts.new({
        content: row['content'],
        url: row['url'],
        created_at: row['created_at'],
        user_id: row['user_id'],
        id: row['id']
      })
    end if !result.nil? && result.size > 0
    data
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
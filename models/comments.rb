
require_relative '../db/db_connector.rb'

class Comments
  attr_accessor :id, :content, :post_id, :user_id, :created_at, :updated_at, :attachment, :attachment_name

  def initialize(params = {})
    @id = params[:id]
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    @content = params[:content]
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
    @attachment = params[:attachment]
    @attachment_name = params[:attachment_name]
  end

  def save
    return false unless valid?

    client = create_db_client
    client.query("INSERT INTO comments (user_id, post_id, content, attachment, attachment_name) VALUES (#{user_id}, #{post_id}, '#{content}', '#{attachment}', '#{attachment_name}')")
    client.last_id
  end

  def update
    return false unless valid?
    return false unless valid_id?

    client = create_db_client
    client.query("UPDATE comments SET content = '#{content}', attachment = '#{attachment}', attachment_name = '#{attachment_name}', updated_at = NOW() WHERE id = #{id}")
    true
  end

  def delete
    return false unless valid_id?

    client = create_db_client
    client.query("DELETE FROM comments WHERE id = #{@id}")
    true
  end

  def self.remove_by_id(id)
    Comments.new({ id: id }).delete
    true
  end

  def self.find_all
    client = create_db_client
    result = client.query("SELECT * FROM comments")
    convert_sql_result_to_array(result)
  end

  def self.find_by_id(id)
    client = create_db_client
    result = client.query("SELECT * FROM comments WHERE id = #{id}")
    convert_sql_result_to_array(result)[0]
  end

  def self.find_by_post_id(post_id)
    client = create_db_client
    result = client.query("SELECT * FROM comments WHERE post_id = #{post_id}")
    convert_sql_result_to_array(result)[0]
  end

  def self.find_by_hashtag(hashtag)
    client = create_db_client
    result = client.query("SELECT * FROM comments WHERE content LIKE '%#{hashtag}%'")
    convert_sql_result_to_array(result)[0]
  end

  def self.convert_sql_result_to_array(result)
    data = []
    result.each do |row|
      data << Comments.new({
        content: row['content'],
        attachment: row['attachment'],
        attachment_name: row['attachment_name'],
        updated_at: row['updated_at'],
        created_at: row['created_at'],
        post_id: row['post_id'],
        user_id: row['user_id'],
        id: row['id']
      })
    end if !result.nil? && result.size > 0
    data
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
require_relative '../db/db_connector.rb'

class Users
  attr_accessor :id, :username, :email, :bio

  def initialize(params = {})
    @id = params[:id]
    @username = params[:username]
    @email = params[:email]
    @bio = params[:bio]
  end

  def self.find_by_username(username)
    client = create_db_client
    result = client.query("SELECT * FROM users WHERE username = '#{username}'")
    convert_sql_result_to_array(result)[0]
  end

  def self.find_by_id(id)
    client = create_db_client
    result = client.query("SELECT * FROM users WHERE id = #{id}")
    convert_sql_result_to_array(result)[0]
  end

  def self.find_all
    client = create_db_client
    result = client.query("SELECT * FROM users")
    convert_sql_result_to_array(result)
  end

  def save
    return false unless valid?
    
    client = create_db_client
    client.query("INSERT INTO users (username, email, bio) VALUES ('#{@username}', '#{@email}', '#{@bio}')");
    true
  end

  def delete
    return false unless valid_id?

    Users.remove_by_id(@id)
  end

  def self.remove_by_id(id)
    client = create_db_client
    client.query("DELETE FROM users WHERE id = #{id}")
    true
  end

  def update
    return false unless valid_all?

    client = create_db_client
    client.query("UPDATE users SET username='#{username}', email='#{email}', bio='#{bio}' WHERE id=#{id}")
    true
  end

  def valid_id?
    return false if id.nil?
    return false if id.to_i == 0
    return false if !id.positive?
    true
  end

  def valid_email?
    (email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def valid?
    return false if @username.nil?
    return false unless valid_email?
    return false if @bio.nil?
    true
  end

  def valid_all?
    return false unless valid?
    return false unless valid_id?
    true
  end

  def self.convert_sql_result_to_array(result)
    data = []
    result.each do |row|
      data << Users.new({
        username: row['username'],
        bio: row['bio'],
        email: row['email'],
        id: row['id']
      })
    end if !result.nil? && result.size > 0
    data
  end
end
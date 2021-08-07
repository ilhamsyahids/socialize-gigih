require_relative '../db/db_connector.rb'

class Users
  attr_accessor :id, :username, :email, :bio

  def initialize(params = {})
    @id = params[:id]
    @username = params[:username]
    @email = params[:email]
    @bio = params[:bio]
  end

  def save
    return false unless valid?
    
    client = create_db_client
    client.query("INSERT INTO users (username, email, bio) VALUES ('#{@username}', '#{@email}', '#{@bio}')");
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
end
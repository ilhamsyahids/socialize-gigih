require_relative '../db/db_connector.rb'

class Users
  attr_accessor :id, :username, :email, :bio

  def initialize(params = {})
    @id = params[:id]
    @username = params[:username]
    @email = params[:email]
    @bio = params[:bio]
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
end
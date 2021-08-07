require 'mysql2'

def create_db_client
  db = Mysql2::Client.new(
    :host => 'localhost',
    :username => 'root',
    :password => 'root',
    :database => 'socialize_db'
  )
  db
end

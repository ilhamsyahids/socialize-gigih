require 'mysql2'

def create_db_client
  db = Mysql2::Client.new(
    :host => ENV['DB_HOST'] || 'localhost',
    :username => ENV['DB_USERNAME'] || 'root',
    :password => ENV['DB_PASSWORD'] || 'root',
    :database => ENV['DB_DATABASE'] || 'socialize_db'
  )
  db
end

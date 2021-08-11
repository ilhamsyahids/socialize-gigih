
require_relative '../models/users.rb'

class UsersController
  def create_item(params)
    user = Users.new(params)
    user.save
  end
end

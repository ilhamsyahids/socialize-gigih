
require_relative '../../models/users'
require_relative '../../controllers/users_controller.rb'

describe UsersController do
  before(:each) do
    $users_controller = UsersController.new

    $client = create_db_client
    $client.query("TRUNCATE users")
  end

  after(:all) do
    $client.query("TRUNCATE users")
  end

  describe '#create' do
    context 'when given valid params' do
      it 'should create item' do
        params = {
          username: 'ilham',
          email: 'foo@bar.com',
          bio: 'Haloo'
        }

        id = $users_controller.create_item(params)

        user = Users.find_by_id(id)

        expect(user).to_not be_nil
        expect(user.username).to eq('ilham')
        expect(user.email).to eq('foo@bar.com')
        expect(user.bio).to eq('Haloo')
      end
    end

    context 'when already exists' do
      it 'username should raise error' do
        params = {
          username: 'ilham',
          email: 'foo@bar.com',
          bio: 'Haloo'
        }

        $users_controller.create_item(params)

        begin
          $users_controller.create_item(params)
        rescue Mysql2::Error => exception
          response = exception.message
        ensure
          expect(response).to eql("Duplicate entry '#{params[:username]}' for key 'username'")
        end
      end
      it 'username should raise error' do
        params = {
          username: 'ilham',
          email: 'foo@bar.com',
          bio: 'Haloo'
        }

        $users_controller.create_item(params)

        params[:username] = 'il'

        begin
          $users_controller.create_item(params)
        rescue Mysql2::Error => exception
          response = exception.message
        ensure
          expect(response).to eql("Duplicate entry '#{params[:email]}' for key 'email'")
        end
      end
    end
  end

end
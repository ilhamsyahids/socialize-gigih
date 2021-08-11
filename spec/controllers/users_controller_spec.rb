
require_relative '../../models/users'
require_relative '../../controllers/users_controller.rb'

describe UsersController do
  before(:each) do
    $users_controller = UsersController.new

    $client = create_db_client
    $client.query("TRUNCATE users")
    $client.query("TRUNCATE posts")
  end

  after(:all) do
    $client.query("TRUNCATE users")
    $client.query("TRUNCATE posts")
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

  describe 'searching' do
    describe '#find_users_by_id' do
      context 'when given valid id' do
        it 'should find user' do
          params = {
            username: 'ilham',
            email: 'foo@bar.com',
            bio: 'Haloo'
          }

          id = $users_controller.create_item(params)

          user = $users_controller.find_users_by_id(id)

          expect(user.id).to eq(id)
          expect(user.username).to eq("ilham")
          expect(user.bio).to eq("Haloo")
          expect(user.email).to eq("foo@bar.com")
        end
      end
    end

    describe '#find_users_by_username' do
      context 'when given valid username' do
        it 'should find user' do
          params = {
            username: 'ilham',
            email: 'foo@bar.com',
            bio: 'Haloo'
          }

          id = $users_controller.create_item(params)

          user = $users_controller.find_users_by_username(params[:username])

          expect(user.id).to eq(id)
          expect(user.username).to eq('ilham')
          expect(user.bio).to eq("Haloo")
          expect(user.email).to eq('foo@bar.com')
        end
      end
    end

    describe '#find_all_users' do
      it 'should find all users' do
        params = {
          username: 'ilham',
          email: 'foo@bar.com',
          bio: 'Haloo'
        }

        users = Users.find_all

        response = $users_controller.find_all_users

        expect(users).to eq(response)

        id = $users_controller.create_item(params)

        response = $users_controller.find_all_users

        user = response.first

        expect(user.id).to eq(id)
        expect(user.username).to eq("ilham")
        expect(user.bio).to eq("Haloo")
        expect(user.email).to eq('foo@bar.com')
      end
    end

    describe '#find_users_with_posts_by_id' do
      context 'when no post' do
        it 'should find user without posts' do
          params = {
            username: 'ilham',
            email: 'foo@bar.com',
            bio: 'Haloo'
          }

          id = $users_controller.create_item(params)

          user = $users_controller.find_users_with_posts_by_id(id)

          expect(user.posts).to eq([])
        end
      end

      context 'when have post' do
        it 'should find user with posts' do
          params = {
            username: 'ilham',
            email: 'foo@bar.com',
            bio: 'Haloo'
          }

          id = $users_controller.create_item(params)

          Posts.new({
            user_id: id,
            content: 'when'
          }).save

          user = $users_controller.find_users_with_posts_by_id(id)

          expect(user.posts.length).to eq(1)
          expect(user.posts[0].user_id).to eq(1)
          expect(user.posts[0].content).to eq('when')
        end
      end
    end

  end

end
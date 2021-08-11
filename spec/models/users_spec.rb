
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/users.rb'
require_relative '../../db/db_connector.rb'

describe Users do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE users")
  end

  after(:all) do
    $client.query("TRUNCATE users")
    $client.query("TRUNCATE posts")
  end

  describe "validity" do
    context "#valid_id" do
      it 'positif integer should valid' do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_id?).to be_truthy
      end

      it 'negatif should not valid' do
        model = Users.new({
          id: -1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_id?).to be_falsey
      end

      it 'negatif should not valid' do
        model = Users.new({
          id: 0,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_id?).to be_falsey
      end

      it 'string should not valid' do
        model = Users.new({
          id: 'dwd',
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_id?).to be_falsey
      end
    end

    context "#valid_email" do
      it 'should valid' do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_email?).to be_truthy
      end

      it 'should not valid' do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foobar'
        })

        expect(model.valid_email?).to be_falsey
      end
    end

    context "#valid_all" do
      it 'should valid' do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_all?).to be_truthy
      end

      it 'should not valid' do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid_all?).to be_falsey
      end
    end

    context "#valid" do
      it 'should valid' do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        expect(model.valid?).to be_truthy
      end

      it 'should not valid' do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
        })

        expect(model.valid?).to be_falsey
      end
    end
  end

  describe "create" do
    context "#save" do
      it "should have correct query" do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("INSERT INTO users (username, email, bio) VALUES ('#{model.username}', '#{model.email}', '#{model.bio}')");

        expect(model.save).to be_truthy
      end

      it "should insert into table" do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        result = $client.query("SELECT * FROM users")
        expect(result.size).to eq(1)

        user = result.first
        expect(user["username"]).to eq('aaa')
        expect(user["email"]).to eq('foo@bar.com')
        expect(user["bio"]).to eq('Haloo')
      end
    end
  end

  describe "delete" do
    context "#delete" do
      it "should have correct query" do
        model = Users.new({ id: 1 })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("DELETE FROM users WHERE id = #{model.id}");

        expect(model.delete).to be_truthy
      end

      it "should delete from table" do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        result = $client.query("SELECT * FROM users")
        expect(result.size).to eq(1)

        model.delete

        result = $client.query("SELECT * FROM users")
        expect(result.size).to eq(0)
      end
    end

    context "#remove_by_id" do
      it "should have correct query" do
        model = Users.new({ id: 1 })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("DELETE FROM users WHERE id = #{model.id}");

        expect(Users.remove_by_id(model.id)).to be_truthy
      end

      it "should delete from table" do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        result = $client.query("SELECT * FROM users")
        expect(result.size).to eq(1)

        Users.remove_by_id(model.id)

        result = $client.query("SELECT * FROM users")
        expect(result.size).to eq(0)
      end
    end
  end

  describe "update" do
    context "#update" do
      it "should have correct query" do
        model = Users.new({
          id: 1,
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("UPDATE users SET username='#{model.username}', email='#{model.email}', bio='#{model.bio}' WHERE id=#{model.id}");

        expect(model.update).to be_truthy
      end

      it "should update the table" do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        model.id = 1
        model.username = "abc"
        model.email = "bar@foo.com"
        model.bio = "hai"

        expect(model.update).to be_truthy

        result = $client.query("SELECT * FROM users")
        user = result.first

        expect(user["username"]).to eq("abc")
        expect(user["email"]).to eq("bar@foo.com")
        expect(user["bio"]).to eq("hai")
      end
    end
  end

  describe "searching" do
    context "#find_all" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM users")

        expect(Users.find_all).to eq([])
      end

      it 'should find all from table' do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        model = Users.new({
          username: 'aba',
          bio: 'hai',
          email: 'bar@foo.com'
        })
        model.save

        users = Users.find_all
        expect(users.size).to eq(2)

        first = users.first
        expect(first.id).to eq(1)
        expect(first.username).to eq("aaa")
        expect(first.bio).to eq("Haloo")
        expect(first.email).to eq("foo@bar.com")

        last = users.last
        expect(last.id).to eq(2)
        expect(last.username).to eq("aba")
        expect(last.bio).to eq("hai")
        expect(last.email).to eq("bar@foo.com")
      end
    end

    context "#find_by_id" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM users WHERE id = 1")

        user = Users.find_by_id(1)

        expect(user).to eq(nil)
      end

      it 'should find by id from table' do
        model = Users.new({
          username: 'aaa',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        user = Users.find_by_id(1)

        expect(user.id).to eq(1)
        expect(user.username).to eq("aaa")
        expect(user.bio).to eq("Haloo")
        expect(user.email).to eq("foo@bar.com")
      end
    end

    context "#find_by_username" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM users WHERE username = 'ilhamsyahids'")

        user = Users.find_by_username("ilhamsyahids")

        expect(user).to eq(nil)
      end

      it 'should find by id from table' do
        model = Users.new({
          username: 'ilhamsyahids',
          bio: 'Haloo',
          email: 'foo@bar.com'
        })

        model.save

        user = Users.find_by_username('ilhamsyahids')

        expect(user.id).to eq(1)
        expect(user.username).to eq("ilhamsyahids")
        expect(user.bio).to eq("Haloo")
        expect(user.email).to eq("foo@bar.com")
      end
    end
  end

  describe 'add post' do
    before(:each) do
      $client.query("TRUNCATE posts")
    end

    context '#add_post' do
      it 'should insert into table' do
        user = Users.new({
          id: 1
        })

        response = user.add_post({
          content: 'Haloo',
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        })
        expect(response).to be_truthy
        
        result = $client.query("SELECT * FROM posts")

        expect(result.size).to eq(1)

        expect(result.first["content"]).to eq('Haloo')
        expect(result.first["attachment"]).to eq('png/a.png')
        expect(result.first["attachment_name"]).to eq('aws.png')
        expect(result.first["user_id"]).to eq(1)
      end
    end
  end

  describe "utils" do
    context "convert model user to json" do
      it "should convert correct to json" do
        array = Array.new([
          Users.new({ id: 1, email: 'foo@bar.com', bio: 'Haloo', username: 'aaa' }),
          Users.new({ id: 2, email: 'bar@bar.com', bio: 'hai', username: 'aba' })
        ])
  
        json = Users.convert_models_to_json(array).to_json
        json_expected = "{\"users\":[{\"id\":1,\"username\":\"aaa\",\"email\":\"foo@bar.com\",\"bio\":\"Haloo\"},{\"id\":2,\"username\":\"aba\",\"email\":\"bar@bar.com\",\"bio\":\"hai\"}]}"
  
        expect(json).to eq(json_expected)
      end
    end
  end

end
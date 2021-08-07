
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/users.rb'
require_relative '../../db/db_connector.rb'

describe Users do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE users")
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

end

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
end
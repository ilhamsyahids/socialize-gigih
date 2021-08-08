
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/posts.rb'
require_relative '../../db/db_connector.rb'

describe Posts do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE posts")
  end

  describe "validity" do
    context "#valid" do
      describe 'by email' do
        it 'should valid without url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post'
          })
  
          expect(model.valid_url?).to be_truthy
        end

        it 'should valid with correct url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post',
            url: 'http://example.com'
          })
  
          expect(model.valid_url?).to be_truthy
        end

        it 'should invalid with invalid url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post',
            url: 'http://example .com'
          })
  
          expect(model.valid_url?).to be_falsey
        end
      end

      describe 'by content' do
        it 'should valid with < 1000 chars' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'a' * 999
          })
  
          expect(model.valid_content?).to be_truthy
        end

        it 'should valid with 1000 chars' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'a' * 1000
          })
  
          expect(model.valid_content?).to be_truthy
        end

        it 'should invalid with > 1000 chars' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'a' * 1001
          })
  
          expect(model.valid_content?).to be_falsey
        end

        it 'should invalid with 0 chars' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: ''
          })
  
          expect(model.valid_content?).to be_falsey
        end

        it 'should invalid without content' do
          model = Posts.new({
            id: 1,
            user_id: 1
          })
  
          expect(model.valid_content?).to be_falsey
        end
      end

      describe 'by user_id' do
        it 'should valid with correct user' do
          model = Posts.new({ user_id: 1 })
  
          expect(model.valid_user?).to be_truthy
        end

        it 'should invalid without user_id' do
          model = Posts.new({ id: 1 })
  
          expect(model.valid_user?).to be_falsey
        end

        it 'should invalid with wrong user_id' do
          model = Posts.new({ id: 1, user_id: 'ad' })
  
          expect(model.valid?).to be_falsey
        end
      end

      describe 'by id' do
        it 'should valid with correct id' do
          model = Posts.new({ id: 1 })
  
          expect(model.valid_id?).to be_truthy
        end

        it 'should invalid without id' do
          model = Posts.new({ })
  
          expect(model.valid_id?).to be_falsey
        end

        it 'should invalid with wrong id' do
          model = Posts.new({ id: -1 })
  
          expect(model.valid_id?).to be_falsey
        end
      end

      it 'should valid with correct posts property' do
        model = Posts.new({
          id: 1,
          user_id: 1,
          content: 'new post',
          url: 'http://example.com'
        })

        expect(model.valid?).to be_truthy
      end
    end
  end

  describe "create" do
    context "#save" do
      it "should have correct query" do
        model = Posts.new({
          user_id: 1,
          content: 'a'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("INSERT INTO posts (user_id, content, url) VALUES (#{model.user_id}, '#{model.content}', '#{model.url}')")

        expect(model.save).to be_truthy
      end

      it "should insert into table" do
        model = Posts.new({
          user_id: 1,
          content: 'a'
        })

        model.save

        posts = $client.query("SELECT * FROM posts")
        expect(posts.size).to eq(1)

        first_model = posts.first

        expect(first_model["content"]).to eq("a")
        expect(first_model["user_id"]).to eq("1")
        expect(first_model["url"]).to eq('')
      end
    end
  end
end
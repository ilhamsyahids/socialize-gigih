
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/posts.rb'
require_relative '../../db/db_connector.rb'

describe Posts do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE posts")
  end

  after(:all) do
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
  
          expect(model.valid_attachment?).to be_truthy
        end

        it 'should valid with correct url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post',
            attachment: 'png/a.png',
            attachment_name: 'aaaa.png'
          })
  
          expect(model.valid_attachment?).to be_truthy
        end

        it 'should invalid with invalid url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post',
            attachment: 'png/' + ('a' * 252)
          })
  
          expect(model.valid_attachment?).to be_falsey
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
          url: 'png/a.png'
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
        allow(mock_client).to receive(:last_id).and_return(1)
        expect(mock_client).to receive(:query).with("INSERT INTO posts (user_id, content, attachment, attachment_name) VALUES (#{model.user_id}, '#{model.content}', '#{model.attachment}', '#{model.attachment_name}')")

        expect(model.save).to_not be_nil
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
        expect(first_model["user_id"]).to eq(1)
        expect(first_model["attachment_name"]).to eq('')
        expect(first_model["attachment"]).to eq('')
      end
    end
  end

  describe "update" do
    context "#update" do
      it "should have correct query" do
        model = Posts.new({
          user_id: 1,
          id: 1,
          content: "#database",
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("UPDATE posts SET content = '#{model.content}', attachment = '#{model.attachment}', attachment_name = '#{model.attachment_name}', updated_at = NOW() WHERE id = #{model.id}")

        expect(model.update).to be_truthy
      end

      it "should updated in database" do
        model = Posts.new({
          user_id: 1,
          content: "ini adalah #database"
        })

        model.save

        model.id = 1
        model.content = "ini merupakan #mysql"
        model.attachment = 'png/a.png'

        model.update

        posts = $client.query("SELECT * FROM posts")
        
        first_model = posts.first

        expect(first_model["content"]).to eq("ini merupakan #mysql")
        expect(first_model["attachment"]).to eq('png/a.png')
      end
    end
  end

  describe "delete" do
    context "#delete" do
      it "should have correct query" do
        model = Posts.new({ id: 1 })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("DELETE FROM posts WHERE id = #{model.id}");

        expect(model.delete).to be_truthy
      end

      it "should delete from table" do
        model = Posts.new({
          user_id: 1,
          content: "database",
          url: 'png/a.png'
        })

        model.save

        result = $client.query("SELECT * FROM posts")
        expect(result.size).to eq(1)

        model.id = 1

        model.delete

        result = $client.query("SELECT * FROM posts")
        expect(result.size).to eq(0)
      end
    end

    context "#remove_by_id" do
      it "should have correct query" do
        model = Posts.new({ id: 1 })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("DELETE FROM posts WHERE id = #{model.id}");

        expect(Posts.remove_by_id(model.id)).to be_truthy
      end

      it "should delete from table" do
        model = Posts.new({
          id: 1,
          user_id: 1,
          content: 'aaa',
          url: 'png/a.png'
        })

        model.save

        result = $client.query("SELECT * FROM posts")
        expect(result.size).to eq(1)

        Posts.remove_by_id(model.id)

        result = $client.query("SELECT * FROM posts")
        expect(result.size).to eq(0)
      end
    end
  end

  describe "searching" do
    context "#find_all" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM posts")

        expect(Posts.find_all).to eq([])
      end

      it 'should find all from table' do
        model = Posts.new({
          user_id: 1,
          content: "ini adalah #database",
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        })

        model.save

        model = Posts.new({
          user_id: 2,
          content: "ini adalah #mysql"
        })
        model.save

        posts = Posts.find_all
        expect(posts.size).to eq(2)

        first = posts.first
        expect(first.id).to eq(1)
        expect(first.user_id).to eq(1)
        expect(first.content).to eq("ini adalah #database")
        expect(first.attachment_name).to eq("aws.png")
        expect(first.attachment).to eq("png/a.png")

        last = posts.last
        expect(last.id).to eq(2)
        expect(last.user_id).to eq(2)
        expect(last.content).to eq("ini adalah #mysql")
        expect(last.attachment_name).to eq("")
        expect(last.attachment).to eq("")
      end
    end

    context "#find_by_id" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM posts WHERE id = 1")

        post = Posts.find_by_id(1)

        expect(post).to eq(nil)
      end

      it 'should find by id from table' do
        model = Posts.new({
          user_id: 1,
          content: "ini adalah #database",
          attachment: 'png/a.png'
        })

        model.save

        post = Posts.find_by_id(1)

        expect(post.id).to eq(1)
        expect(post.user_id).to eq(1)
        expect(post.content).to eq("ini adalah #database")
        expect(post.attachment).to eq("png/a.png")
      end
    end

    context "#find_by_user_id" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM posts WHERE user_id = 1")

        post = Posts.find_by_user_id(1)

        expect(post).to eq(nil)
      end

      it 'should find by id from table' do
        model = Posts.new({
          user_id: 2,
          content: "ini adalah #database",
          attachment: 'png/a.png'
        })

        model.save

        post = Posts.find_by_user_id(2)

        expect(post.id).to eq(1)
        expect(post.user_id).to eq(2)
        expect(post.content).to eq("ini adalah #database")
        expect(post.attachment).to eq("png/a.png")
      end
    end

    context "#find_by_hashtag" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM posts WHERE content LIKE '%#database%'")

        post = Posts.find_by_hashtag('#database')

        expect(post).to eq(nil)
      end

      it 'should find by id from table' do
        model = Posts.new({
          user_id: 2,
          content: "ini adalah #database",
          attachment: 'png/a.png'
        })

        model.save

        post = Posts.find_by_hashtag('#database')

        expect(post.id).to eq(1)
        expect(post.user_id).to eq(2)
        expect(post.content).to eq("ini adalah #database")
        expect(post.attachment).to eq("png/a.png")
      end
    end
  end
end


require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/comments.rb'
require_relative '../../db/db_connector.rb'

describe Comments do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE comments")
  end

  after(:all) do
    $client.query("TRUNCATE comments")
  end

  describe "validity" do
    context "#valid" do
      describe 'by content' do
        it 'should valid with < 1000 chars' do
          model = Comments.new({
            id: 1,
            user_id: 1,
            content: 'a' * 999
          })
  
          expect(model.valid_content?).to be_truthy
        end

        it 'should valid with 1000 chars' do
          model = Comments.new({
            id: 1,
            user_id: 1,
            content: 'a' * 1000
          })
  
          expect(model.valid_content?).to be_truthy
        end

        it 'should invalid with > 1000 chars' do
          model = Comments.new({
            id: 1,
            user_id: 1,
            content: 'a' * 1001
          })
  
          expect(model.valid_content?).to be_falsey
        end

        it 'should invalid with 0 chars' do
          model = Comments.new({
            id: 1,
            user_id: 1,
            content: ''
          })
  
          expect(model.valid_content?).to be_falsey
        end

        it 'should invalid without content' do
          model = Comments.new({
            id: 1,
            user_id: 1
          })
  
          expect(model.valid_content?).to be_falsey
        end
      end

      describe 'by user_id' do
        it 'should valid with correct user' do
          model = Comments.new({ user_id: 1 })
  
          expect(model.valid_user?).to be_truthy
        end

        it 'should invalid without user_id' do
          model = Comments.new({ id: 1 })
  
          expect(model.valid_user?).to be_falsey
        end

        it 'should invalid with wrong user_id' do
          model = Comments.new({ id: 1, user_id: 'ad' })
  
          expect(model.valid_user?).to be_falsey
        end
      end

      describe 'by post_id' do
        it 'should valid with correct user' do
          model = Comments.new({ post_id: 1 })
  
          expect(model.valid_post?).to be_truthy
        end

        it 'should invalid without post_id' do
          model = Comments.new({ id: 1 })
  
          expect(model.valid_post?).to be_falsey
        end

        it 'should invalid with wrong post_id' do
          model = Comments.new({ id: 1, post_id: 'ad' })
  
          expect(model.valid_post?).to be_falsey
        end
      end

      describe 'by id' do
        it 'should valid with correct id' do
          model = Comments.new({ id: 1 })
  
          expect(model.valid_id?).to be_truthy
        end

        it 'should invalid without id' do
          model = Comments.new({ })
  
          expect(model.valid_id?).to be_falsey
        end

        it 'should invalid with wrong id' do
          model = Comments.new({ id: -1 })
  
          expect(model.valid_id?).to be_falsey
        end
      end

      it 'should valid with correct property' do
        model = Comments.new({
          id: 1,
          user_id: 1,
          post_id: 1,
          content: 'new comment'
        })

        expect(model.valid?).to be_truthy
      end
    end
  end

  describe "create" do
    context "#save" do
      it "should have correct query" do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          content: 'a',
          attachment: 'png/a.png'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive(:last_id).and_return(1)
        expect(mock_client).to receive(:query).with("INSERT INTO comments (user_id, post_id, content, attachment, attachment_name) VALUES (#{model.user_id}, #{model.post_id}, '#{model.content}', '#{model.attachment}', '#{model.attachment_name}')")

        expect(model.save).to_not be_nil
      end

      it "should insert into table" do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          content: 'a',
          attachment: 'png/a.png'
        })

        model.save

        comments = $client.query("SELECT * FROM comments")
        expect(comments.size).to eq(1)

        first_model = comments.first

        expect(first_model["content"]).to eq("a")
        expect(first_model["post_id"]).to eq(1)
        expect(first_model["user_id"]).to eq(1)
        expect(first_model["attachment"]).to eq('png/a.png')
      end
    end
  end

  describe "update" do
    context "#update" do
      it "should have correct query" do
        model = Comments.new({
          id: 1,
          post_id: 1,
          user_id: 1,
          content: 'a',
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("UPDATE comments SET content = '#{model.content}', attachment = '#{model.attachment}', attachment_name = '#{model.attachment_name}', updated_at = NOW() WHERE id = #{model.id}")

        expect(model.update).to be_truthy
      end

      it "should updated in database" do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          attachment: 'png/a.png',
          content: "ini adalah #database"
        })

        model.save

        model.id = 1
        model.content = "ini merupakan #mysql"
        model.attachment = 'jpg/j.jpg'

        model.update

        comments = $client.query("SELECT * FROM comments")
        
        first_model = comments.first

        expect(first_model["content"]).to eq("ini merupakan #mysql")
        expect(first_model["attachment"]).to eq('jpg/j.jpg')
      end
    end
  end

  describe "delete" do
    context "#delete" do
      it "should have correct query" do
        model = Comments.new({ id: 1 })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("DELETE FROM comments WHERE id = #{model.id}");

        expect(model.delete).to be_truthy
      end

      it "should delete from table" do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          content: "database",
        })

        model.save

        result = $client.query("SELECT * FROM comments")
        expect(result.size).to eq(1)

        model.id = 1

        model.delete

        result = $client.query("SELECT * FROM comments")
        expect(result.size).to eq(0)
      end
    end

    context "#remove_by_id" do
      it "should have correct query" do
        model = Comments.new({ id: 1 })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("DELETE FROM comments WHERE id = #{model.id}");

        expect(Comments.remove_by_id(model.id)).to be_truthy
      end

      it "should delete from table" do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          content: 'aaa'
        })

        model.save

        model.id = 1

        result = $client.query("SELECT * FROM comments")
        expect(result.size).to eq(1)

        Comments.remove_by_id(model.id)

        result = $client.query("SELECT * FROM comments")
        expect(result.size).to eq(0)
      end
    end
  end

  describe "searching" do
    context "#find_all" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM comments")

        expect(Comments.find_all).to eq([])
      end

      it 'should find all from table' do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          content: "ini adalah #database"
        })

        model.save

        model = Comments.new({
          post_id: 2,
          user_id: 2,
          content: "ini adalah #mysql"
        })
        model.save

        comments = Comments.find_all
        expect(comments.size).to eq(2)

        first = comments.first
        expect(first.id).to eq(1)
        expect(first.post_id).to eq(1)
        expect(first.user_id).to eq(1)
        expect(first.content).to eq("ini adalah #database")

        last = comments.last
        expect(last.id).to eq(2)
        expect(last.post_id).to eq(2)
        expect(last.user_id).to eq(2)
        expect(last.content).to eq("ini adalah #mysql")
      end
    end

    context "#find_by_id" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM comments WHERE id = 1")

        post = Comments.find_by_id(1)

        expect(post).to eq(nil)
      end

      it 'should find by id from table' do
        model = Comments.new({
          post_id: 1,
          user_id: 1,
          content: "ini adalah #database"
        })

        model.save

        post = Comments.find_by_id(1)

        expect(post.id).to eq(1)
        expect(post.post_id).to eq(1)
        expect(post.user_id).to eq(1)
        expect(post.content).to eq("ini adalah #database")
      end
    end

    context "#find_by_post_id" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM comments WHERE post_id = 1")

        posts = Comments.find_by_post_id(1)

        expect(posts).to eq([])
      end

      it 'should find by id from table' do
        model = Comments.new({
          post_id: 2,
          user_id: 2,
          content: "ini adalah #database"
        })

        model.save

        post = Comments.find_by_post_id(2).first

        expect(post.id).to eq(1)
        expect(post.post_id).to eq(2)
        expect(post.user_id).to eq(2)
        expect(post.content).to eq("ini adalah #database")
      end
    end

    context "#find_by_hashtag" do
      it 'should have correct query' do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM comments WHERE content LIKE '%#database%'")

        posts = Comments.find_by_hashtag('#database')

        expect(posts).to eq([])
      end

      it 'should find by id from table' do
        model = Comments.new({
          post_id: 2,
          user_id: 2,
          content: "ini adalah #database",
        })

        model.save

        post = Comments.find_by_hashtag('#database').first

        expect(post.id).to eq(1)
        expect(post.post_id).to eq(2)
        expect(post.user_id).to eq(2)
        expect(post.content).to eq("ini adalah #database")
      end
    end
  end

end

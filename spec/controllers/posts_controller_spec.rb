
require_relative '../test_helper.rb'
require_relative '../../models/posts'
require_relative '../../controllers/posts_controller.rb'

describe PostsController do
  before(:each) do
    $posts_controller = PostsController.new

    $client = create_db_client
    $client.query("TRUNCATE posts")
    $client.query("TRUNCATE hashtags")
  end

  after(:all) do
    $client.query("TRUNCATE posts")
    $client.query("TRUNCATE hashtags")
  end

  describe '#create' do
    context 'when given valid params' do
      it 'should create post' do
        params = {
          user_id: 1,
          content: "#database #database",
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        }

        id = $posts_controller.create_post(params)

        post = Posts.find_by_id(id)

        hashtag = Hashtags.find_by_content('#database')

        expect(post).to_not be_nil
        expect(post.user_id).to eq(1)
        expect(post.content).to eq("#database #database")
        expect(post.attachment).to eq('png/a.png')
        expect(post.attachment_name).to eq('aws.png')

        expect(hashtag.counter).to eq(1)
      end
    end
    context 'when given invalid params' do
      it 'should not create post' do
        params = {
          user_id: 1
        }

        expect($posts_controller.create_post(params)).to eq(false)
      end
    end
  end

  describe 'searching' do
    context '#find_all' do
      it 'should valid' do
        expect($posts_controller.find_all).to eq([])

        $posts_controller.create_post({ user_id: 1, content: '#database' })

        expect($posts_controller.find_all.length).to eq(1)
      end
    end

    context '#find_by_user_id' do
      it 'should valid' do
        expect($posts_controller.find_by_user_id(1)).to eq([])
        $posts_controller.create_post({ user_id: 1, content: '#database' })
        expect($posts_controller.find_by_user_id(1).length).to eq(1)
      end
    end

    context '#find_by_hashtag' do
      it 'should valid' do
        expect($posts_controller.find_by_hashtag('database')).to eq([])
        $posts_controller.create_post({ user_id: 1, content: '#database' })
        expect($posts_controller.find_by_hashtag('database').length).to eq(1)
      end
    end

    context '#find_by_id' do
      it 'should valid' do
        expect($posts_controller.find_by_id(1)).to eq(nil)
        $posts_controller.create_post({ user_id: 1, content: '#database' })
        post = $posts_controller.find_by_id(1)

        expect(post.user_id).to eq(1)
        expect(post.content).to eq('#database')
      end
    end
  end

  describe '#delete_post' do
    context 'when post in last 24 hours' do
      it 'should delete post and the hashtags' do
        params = {
          user_id: 1,
          content: "aa #database",
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        }

        id = $posts_controller.create_post(params)

        $posts_controller.delete_post(id)

        hashtag = Hashtags.find_by_content('#database')

        expect(hashtag.counter).to eq(0)
      end
    end

    context 'when post out last 24 hours' do
      it 'should delete post, not delete hashtags' do
        $client.query("INSERT INTO posts (user_id, content, attachment, attachment_name, created_at) VALUES (1, '#database', '', '', NOW() - INTERVAL 24 HOUR - INTERVAL 1 SECOND)")
        HashtagsController.create('#database')

        $posts_controller.delete_post(1)

        hashtag = Hashtags.find_by_content('#database')

        expect(hashtag.counter).to eq(1)
      end
    end
  end
end

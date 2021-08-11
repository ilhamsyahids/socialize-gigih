
require_relative '../test_helper.rb'
require_relative '../../models/posts'
require_relative '../../controllers/comments_controller.rb'

describe CommentsController do
  before(:each) do
    $comments_controller = CommentsController.new

    $client = create_db_client
    $client.query("TRUNCATE comments")
    $client.query("TRUNCATE hashtags")
  end

  after(:all) do
    $client.query("TRUNCATE comments")
    $client.query("TRUNCATE hashtags")
  end

  describe '#create' do
    context 'when given valid params' do
      it 'should create comment' do
        params = {
          post_id: 1,
          user_id: 1,
          content: "#database #sql #database",
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        }

        id = $comments_controller.create_comment(params)

        comment = Comments.find_by_id(id)

        expect(comment).to_not be_nil
        expect(comment.user_id).to eq(1)
        expect(comment.content).to eq("#database #sql #database")
        expect(comment.attachment).to eq('png/a.png')
        expect(comment.attachment_name).to eq('aws.png')

        hashtag1 = Hashtags.find_by_content('#database')
        hashtag2 = Hashtags.find_by_content('#sql')

        expect(hashtag1.counter).to eq(1)
        expect(hashtag2.counter).to eq(1)
      end
    end
    context 'when given invalid params' do
      it 'should not create post' do
        params = {
          content: '#database',
          user_id: 1
        }

        expect($comments_controller.create_comment(params)).to eq(false)

        hashtag = Hashtags.find_by_content('#database')

        expect(hashtag).to eq(nil)
      end
    end
  end

  describe 'searching' do
    context '#find_all' do
      it 'should valid' do
        expect($comments_controller.find_all).to eq([])

        $comments_controller.create_comment({ post_id: 1, user_id: 1, content: '#database' })

        expect($comments_controller.find_all.length).to eq(1)
      end
    end

    context '#find_by_post_id' do
      it 'should valid' do
        expect($comments_controller.find_by_post_id(1)).to eq([])
        $comments_controller.create_comment({ post_id: 1, user_id: 1, content: '#database' })
        expect($comments_controller.find_by_post_id(1).length).to eq(1)
      end
    end

    context '#find_by_id' do
      it 'should valid' do
        expect($comments_controller.find_by_id(1)).to eq(nil)
        $comments_controller.create_comment({ post_id: 1, user_id: 1, content: '#database' })
        post = $comments_controller.find_by_id(1)

        expect(post.user_id).to eq(1)
        expect(post.content).to eq('#database')
      end
    end
  end
end

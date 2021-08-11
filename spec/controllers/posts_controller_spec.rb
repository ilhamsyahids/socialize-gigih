
require_relative '../../models/posts'
require_relative '../../controllers/posts_controller.rb'

describe PostsController do
  before(:each) do
    $posts_controller = PostsController.new

    $client = create_db_client
    $client.query("TRUNCATE posts")
  end

  describe '#create' do
    context 'when given valid params' do
      it 'should create item' do
        params = {
          user_id: 1,
          content: "#database",
          attachment: 'png/a.png',
          attachment_name: 'aws.png'
        }

        id = $posts_controller.create_post(params)

        post = Posts.find_by_id(id)

        expect(post).to_not be_nil
        expect(post.user_id).to eq(1)
        expect(post.content).to eq("#database")
        expect(post.attachment).to eq('png/a.png')
        expect(post.attachment_name).to eq('aws.png')
      end
    end
  end
end

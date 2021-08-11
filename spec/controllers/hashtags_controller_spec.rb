
require_relative '../../models/hashtags'
require_relative '../../controllers/hashtags_controller.rb'

describe HashtagsController do
  before(:each) do
    $hashtags_controller = HashtagsController.new

    $client = create_db_client
    $client.query("TRUNCATE hashtags")
  end

  after(:all) do
    $client.query("TRUNCATE hashtags")
  end

  describe '#create' do
    context 'when no hashtags are defined' do
      it 'should create hashtag' do
        content = '#database'

        $hashtags_controller.create(content)

        hashtag = Hashtags.find_by_content(content)

        expect(hashtag).to_not be_nil
        expect(hashtag.content).to eq(content)
        expect(hashtag.counter).to eq(1)
      end
    end
  end

end

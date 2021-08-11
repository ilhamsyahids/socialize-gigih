
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

    describe 'when already exists' do
      context 'in last 24 hours' do
        it 'should increment counter' do
          content = '#database'

          $hashtags_controller.create(content)
          $hashtags_controller.create(content)

          hashtag = Hashtags.find_by_content(content)

          expect(hashtag).to_not be_nil
          expect(hashtag.content).to eq(content)
          expect(hashtag.counter).to eq(2)
        end
      end

      context 'out last 24 hours' do
        it 'should reset counter' do
          $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#database', 1, NOW() - INTERVAL 24 HOUR - INTERVAL 1 SECOND)")
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

  describe '#decrement_counter' do
    context 'when given content' do
      it 'should decrease by 1' do
        $client.query("INSERT INTO hashtags (content, counter) VALUES ('#database', 12)")
        content = '#database'

        $hashtags_controller.decrement_counter(content)

        hashtag = Hashtags.find_by_content(content)

        expect(hashtag).to_not be_nil
        expect(hashtag.content).to eq(content)
        expect(hashtag.counter).to eq(11)
      end
    end
  end

end

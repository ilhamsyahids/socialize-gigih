
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/hashtags.rb'
require_relative '../../db/db_connector.rb'

describe Hashtags do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE hashtags")
  end

  describe "validity" do

    context "#valid" do
      it 'should valid' do
        model = Hashtags.new({:content => '#database'})

        expect(model.valid?).to be_truthy
      end

      it 'should not valid without #' do
        model = Hashtags.new({:content => 'database'})

        expect(model.valid?).to be_falsey
      end

      it 'should not valid only #' do
        model = Hashtags.new({:content => '#'})

        expect(model.valid?).to be_falsey
      end
    end
  end

  describe "create" do
    context "#save" do
      it "should have correct query" do
        model = Hashtags.new({
          content: "#database"
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("INSERT INTO hashtags (content, counter) VALUES ('#{model.content}', 1)")

        expect(model.save).to be_truthy
      end

      it "should insert into table" do
        model = Hashtags.new({
          content: "#database"
        })

        time_now = Time.now
        model.save

        hashtags = $client.query("SELECT * FROM hashtags")
        expect(hashtags.size).to eq(1)

        first_hashtag = hashtags.first

        time_diff = (time_now - first_hashtag["updated_at"]).to_i

        expect(first_hashtag["content"]).to eq("#database")
        expect(first_hashtag["counter"]).to eq(1)
        expect(time_diff).to eq(0)
      end
    end
  end

  describe "update" do
    context "#add_counter" do
      it "should have correct query" do
        model = Hashtags.new({
          content: "#database"
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("UPDATE hashtags SET counter = counter + 1 WHERE content = '#{model.content}'")

        expect(model.add_counter).to be_truthy
      end

      it "should increment counter in database" do
        model = Hashtags.new({
          content: "#database"
        })

        model.save

        hashtags = Hashtags.find_by_content('#database')

        hashtags.add_counter
        hashtags.add_counter

        hashtags = Hashtags.find_by_content('#database')

        expect(hashtags.counter).to eq(3)
      end
    end

    context "#min_counter" do
      it "should have correct query" do
        model = Hashtags.new({
          content: "#database"
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("UPDATE hashtags SET counter = counter - 1 WHERE content = '#{model.content}'")

        expect(model.min_counter).to be_truthy
      end

      it "should decrement counter in database" do
        model = Hashtags.new({
          content: "#database"
        })

        model.save

        hashtags = Hashtags.find_by_content('#database')

        hashtags.add_counter
        hashtags.min_counter

        hashtags = Hashtags.find_by_content('#database')

        expect(hashtags.counter).to eq(1)
      end
    end

    context "#reset_counter" do
      it "should have correct query" do
        model = Hashtags.new({
          content: "#database"
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("UPDATE hashtags SET counter = 1 WHERE content = '#{model.content}'")

        expect(model.reset_counter).to be_truthy
      end

      it "should reset counter to 1 in database" do
        model = Hashtags.new({
          content: "#database"
        })

        model.save

        hashtags = Hashtags.find_by_content('#database')

        hashtags.add_counter
        hashtags.add_counter

        hashtags.reset_counter

        hashtags = Hashtags.find_by_content('#database')

        expect(hashtags.counter).to eq(1)
      end
    end
  end

  describe "searching" do
    context "#trending" do
      it "should have correct query" do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM hashtags WHERE counter > 0 AND updated_at >= NOW() - INTERVAL 1 DAY ORDER BY counter DESC, updated_at DESC LIMIT 5")

        expect(Hashtags.trending).to eq([])
      end

      it 'should not find with counter 0' do
        $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#sql', 0, NOW() - INTERVAL 100 SECOND)")
        $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#database', 0, NOW() - INTERVAL 10 SECOND)")

        expect(Hashtags.trending).to eq([])
      end

      it "should find trending hashtags last 24 hour" do
        # should not be included in trending
        $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#sql', 10000, NOW() - INTERVAL 1 DAY - INTERVAL 1 SECOND)")
        # should be first in trending
        $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#mysql', 1000, NOW() - INTERVAL 23 HOUR)")
        # should be second in trending
        $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#database', 100, NOW())")

        hashtags = Hashtags.trending
        first_hashtag = hashtags.first

        expect(hashtags.size).to eq(2)
        expect(first_hashtag.content).to eq('#mysql')
      end
    end

    context "#find_by_content" do
      it "should have correct query" do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM hashtags WHERE content = '#database'")

        expect(Hashtags.find_by_content('#database')).to eq(nil)
      end

      it "should find hashtags" do
        time_now = Time.now
        $client.query("INSERT INTO hashtags (content, counter, updated_at) VALUES ('#mysql', 1000, NOW() - INTERVAL 23 HOUR)")

        hashtags = Hashtags.find_by_content('#mysql')

        time_diff = time_now - hashtags.updated_at
        time_23_hours_ago = 23 * 60 * 60

        expect(hashtags.content).to eq('#mysql')
        expect(hashtags.counter).to eq(1000)
        expect(time_diff.to_i).to eq(time_23_hours_ago)
      end
    end
  end
end

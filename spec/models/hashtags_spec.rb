
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/hashtags.rb'
require_relative '../../db/db_connector.rb'

describe Hashtags do
  before(:each) do
    $client = create_db_client
    $client.query("TRUNCATE hashtags")
  end

  describe "searching" do
    context "trending hashtags" do
      it "should have correct query" do
        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with("SELECT * FROM hashtags WHERE updated_at >= NOW() - INTERVAL 1 DAY ORDER BY counter DESC, updated_at DESC LIMIT 5")

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
  end
end

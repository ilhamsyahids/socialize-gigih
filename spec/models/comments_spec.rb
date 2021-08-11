
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
end

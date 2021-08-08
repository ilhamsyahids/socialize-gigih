
require 'mysql2'
require_relative '../test_helper.rb'
require_relative '../../models/posts.rb'
require_relative '../../db/db_connector.rb'

describe Posts do
  describe "validity" do
    context "#valid" do
      describe 'by email' do
        it 'should valid without url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post'
          })
  
          expect(model.valid_url?).to be_truthy
        end

        it 'should valid with correct url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post',
            url: 'http://example.com'
          })
  
          expect(model.valid_url?).to be_truthy
        end

        it 'should invalid with invalid url' do
          model = Posts.new({
            id: 1,
            user_id: 1,
            content: 'new post',
            url: 'http://example .com'
          })
  
          expect(model.valid_url?).to be_falsey
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
          url: 'http://example.com'
        })

        expect(model.valid?).to be_truthy
      end
    end
  end

end
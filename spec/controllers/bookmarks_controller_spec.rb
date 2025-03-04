# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarksController do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe '#create' do
    it 'creates a bookmark for the current user' do
      question = FactoryBot.create(:question_traditional)

      expect { post :create, params: { question_id: question.id } }.to change { Bookmark.count }.from(0).to(1)
    end
  end

  describe '#destroy' do
    it 'deletes a bookmark for the current user' do
      question = FactoryBot.create(:question_traditional)
      question.bookmarks.create(user:)

      expect { delete :destroy, params: { id: question.id } }.to change { Bookmark.count }.from(1).to(0)
    end
  end

  describe '#destroy_all' do
    it 'deletes all bookmarks for the current user' do
      question1 = FactoryBot.create(:question_traditional)
      question1.bookmarks.create(user:)
      question2 = FactoryBot.create(:question_traditional)
      question2.bookmarks.create(user:)

      expect { delete :destroy_all }.to change { Bookmark.count }.from(2).to(0)
    end
  end

  describe '#export' do
    let(:question) { FactoryBot.build_stubbed(:question_traditional) }

    before do
      allow(Question).to receive(:where).and_return([question])
    end

    context 'as plain text' do
      it 'returns a txt file' do
        get :export, format: :txt
        expect(response.content_type).to eq('text/plain')
        expect(response.headers['Content-Disposition']).to match(/questions-.*\.txt/)
      end

      it 'includes bookmarked questions in the response' do
        get :export, format: :txt
        expect(response.body).to include(question.text)
      end
    end

    context 'as markdown' do
      it 'returns a md file' do
        get :export, format: :md
        expect(response.content_type).to eq('text/plain')
        expect(response.headers['Content-Disposition']).to match(/questions-.*\.md/)
      end

      it 'includes bookmarked questions in the response' do
        get :export, format: :md
        expect(response.body).to include(question.text)
      end
    end

    context 'as xml' do
      it 'returns an xml file' do
        get :export, format: :xml

        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response).to be_successful
        expect(response.headers['Content-Disposition']).to match(/questions-.*\.xml/)
      end

      context 'when a question has images' do
        let(:question) { FactoryBot.create(:question_traditional, :with_images) }

        it 'send a zip file with the images' do
          get :export, format: :xml

          expect(response.content_type).to eq('application/zip')
          expect(response).to be_successful
          expect(response.headers['Content-Disposition']).to match(/questions-.*\.zip/)
        end
      end
    end

    it 'redirects to the root path if the format is not supported' do
      get :export, params: { format: 'csv' }

      expect(response).to redirect_to(authenticated_root_path)
    end
  end
end

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

  describe '#create_batch' do
    let(:question) { FactoryBot.create(:question_traditional) }

    it 'creates bookmarks for all filtered questions and redirects back with success notice' do
      # The controller now uses filter params to query all matching questions
      expect(Bookmark).to receive(:create_batch_from_ids).and_return(:success)

      post :create_batch, params: {
        search: '',
        selected_keywords: [],
        selected_subjects: [],
        selected_types: [],
        selected_levels: [],
        filter_my_questions: false
      }

      expect(response).to redirect_to(authenticated_root_path)
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
    let(:other_user) { FactoryBot.create(:user) }
    let(:question) { FactoryBot.create(:question_traditional) }
    let(:other_question) { FactoryBot.create(:question_traditional) }
    let(:question_3) { FactoryBot.create(:question_essay) }
    let(:question_4) { FactoryBot.create(:question_essay) }
    let(:current_user) { controller.current_user }

    before do
      question.bookmarks.create(user:)
      other_question.bookmarks.create(user: other_user)
      user.bookmarks.create(question: question_3)
      sign_in user
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when exporting bookmarks' do
      it "only includes the current user's bookmarked questions" do
        get :export, format: :txt
        expect(response.body).to include(question.text)
        expect(response.body).to include(question_3.text)
        expect(response.body).not_to include(other_question.text)
        expect(response.body).not_to include(question_4.text)
      end

      it 'scopes the questions to only those bookmarked by current user' do
        expect(current_user.bookmarks.count).to eq(2)
        expect(current_user.bookmarks.map(&:question)).to include(question, question_3)
        expect(current_user.bookmarks.map(&:question)).not_to include(other_question)
      end
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
        expect(response.body).to include(question_3.text)
      end
    end

    context 'as canvas' do
      let(:question) { FactoryBot.create(:question_traditional, :with_images) }

      it 'send a zip file with the images' do
        get :export, format: :canvas

        expect(response.content_type).to eq('application/zip')
        expect(response).to be_successful
        expect(response.headers['Content-Disposition']).to match(/questions-.*\.zip/)
      end
    end

    it 'redirects to the root path if the format is not supported' do
      get :export, params: { format: 'csv' }

      expect(response).to redirect_to(authenticated_root_path)
    end

    it 'creates a export log' do
      expect { get :export, format: :txt }.to change { ExportLogger.count }.by(user.bookmarks.count)
    end
  end
end

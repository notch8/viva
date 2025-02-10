# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlainTextDownloadsController, type: :controller do
  describe 'GET #download' do
    let(:user) { create(:user) }
    let!(:question) { create(:question_essay) }
    let!(:bookmark) { create(:bookmark, user:, question:) }

    before do
      sign_in user
    end

    it 'returns a text file' do
      get :download
      expect(response.content_type).to eq('text/plain')
      expect(response.headers['Content-Disposition']).to include('questions.txt')
    end

    it 'includes bookmarked questions in the response' do
      get :download
      expect(response.body).to include(question.text)
    end
  end
end

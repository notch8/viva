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
end

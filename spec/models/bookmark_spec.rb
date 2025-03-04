# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:question) }

  describe '.create_batch' do
    let(:user) { create(:user) }
    let(:question_1) { FactoryBot.create(:question_traditional) }
    let(:question_2) { FactoryBot.create(:question_traditional) }
    let(:result) { Bookmark.create_batch(question_ids: "#{question_1.id},#{question_2.id}", user:) }

    it 'creates bookmarks for the given question_ids' do
      expect(result).to eq(:success)
      expect(user.bookmarks.pluck(:question_id)).to contain_exactly(question_1.id, question_2.id)
    end

    it 'returns :error if any bookmark fails to save' do
      allow_any_instance_of(Bookmark).to receive(:save).and_return(false)
      expect(result).to eq(:error)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:text) }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:categories) }
    it { should have_and_belong_to_many(:keywords) }
  end

  describe 'factories' do
    subject { FactoryBot.build(:question) }
    it { should be_valid }
  end

  describe '.filter' do
    it 'filters by keyword' do
      question_1 = FactoryBot.create(:question)
      question_2 = FactoryBot.create(:question)
      question_3 = FactoryBot.create(:question)
      keyword_1 = FactoryBot.create(:keyword)
      keyword_2 = FactoryBot.create(:keyword)
      keyword_3 = FactoryBot.create(:keyword)
      category_1 = FactoryBot.create(:category)
      category_2 = FactoryBot.create(:category)
      category_3 = FactoryBot.create(:category)
      question_1.keywords << keyword_1
      question_1.categories << category_1
      expect(Question.filter(keywords: [keyword_1.name])).to eq([question_1])
      expect(Question.filter(keywords: [keyword_2.name])).to eq([])
      expect(Question.filter(keywords: [keyword_1.name, keyword_2.name])).to eq([])

    end
    
  end
end

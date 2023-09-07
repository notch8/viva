# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:text) }
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:categories) }
    it { is_expected.to have_and_belong_to_many(:keywords) }
  end

  describe 'factories' do
    subject { FactoryBot.build(:question) }

    it { is_expected.to be_valid }
  end

  describe '.filter' do
    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'filters by keyword' do
      # Why this one large test instead of many smaller tests?  Because the setup cost for the state
      # of the data is noticable.  In other words, by running multiple tests with one setup
      # (e.g. the below creation of questions, keywords, and categories) we don't have to pay a
      # setup cost for each individual test.
      question1 = FactoryBot.create(:question)
      question2 = FactoryBot.create(:question)
      question3 = FactoryBot.create(:question)
      keyword1 = FactoryBot.create(:keyword)
      keyword2 = FactoryBot.create(:keyword)
      keyword3 = FactoryBot.create(:keyword)
      category1 = FactoryBot.create(:category)
      category2 = FactoryBot.create(:category)
      category3 = FactoryBot.create(:category)
      question1.keywords << keyword1
      question1.categories << category1
      question2.keywords << keyword2
      question2.keywords << keyword3
      question2.categories << category2
      question2.categories << category3
      question3.categories << category3
      question3.keywords << keyword3

      expect(described_class.filter).to eq([question1, question2, question3])

      expect(described_class.filter(keywords: [keyword1.name])).to eq([question1])
      expect(described_class.filter(keywords: [keyword2.name])).to eq([question2])

      # Demonstrating that we "and together" keywords
      expect(described_class.filter(keywords: [keyword1.name, keyword2.name])).to eq([])

      expect(described_class.filter(keywords: [keyword2.name, keyword3.name])).to eq([question2])

      expect(described_class.filter(keywords: [keyword1.name, keyword3.name])).to eq([])

      # When we mix a category in with a keyword
      expect(described_class.filter(keywords: [keyword1.name, category1.name])).to eq([])

      # When we mix a keyword with a category
      expect(described_class.filter(categories: [keyword1.name, category1.name])).to eq([])

      # When we query only the category
      expect(described_class.filter(categories: [category1.name])).to eq([question1])

      # When we provide both category and keyword
      expect(described_class.filter(categories: [category1.name], keywords: [keyword1.name])).to eq([question1])

      # When nothing meets the criteria
      expect(described_class.filter(categories: [category1.name], keywords: [keyword2.name])).to eq([])
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end
end

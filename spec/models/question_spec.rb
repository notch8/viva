# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Question, type: :model do
  # The base Question instance should never be valid; we want to specify the correct type.
  it_behaves_like "a Question", valid: false

  describe '.descendants' do
    subject { described_class.descendants }

    # rubocop:disable RSpec/ExampleLength
    it do
      is_expected.to(
        match_array([Question::BowTie,
                     Question::DragAndDrop,
                     Question::Matching,
                     Question::SelectAllThatApply,
                     Question::StimulusCaseStudy,
                     Question::Traditional])
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.import_csv' do
    let(:csv) do
      CSV.new("TYPE,,TEXT,ANSWERS,ANSWER_1,ANSWER_2,RIGHT_1,LEFT_1,ANSWER_3\n" \
              "Traditional,,Which one is true?,1,true,false,,,Orc\n" \
              "Matching,,Pair Up,,,,Animal,Cat\n" \
              "SelectAllThatApply,,Which one is affirmative?,\"1,3\",true,false,,,yes\n" \
              "DragAndDrop,,What are Anmials?,\"1,2\",Cat,Dog,,,Shoe\n" \
              "DragAndDrop,,The ___1___ chases ___2___?,\"1,2\",Cat,Mouse,,,Umbrella\n",
              headers: true)
    end

    # rubocop:disable RSpec/ExampleLength
    it "creates multiple question types" do
      expect do
        expect do
          expect do
            expect do
              described_class.import_csv(csv)
            end.to change(Question::Traditional, :count).by(1)
          end.to change(Question::Matching, :count).by(1)
        end.to change(Question::DragAndDrop, :count).by(2)
      end.to change(Question::SelectAllThatApply, :count).by(1)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.import_csv_row' do
    it 'should be implemented by subclasses' do
      expect { described_class.import_csv_row }.to raise_error(NotImplementedError)
    end
  end

  describe '.types' do
    subject { described_class.types }

    # rubocop:disable RSpec/ExampleLength
    it do
      is_expected.to(
        match_array([
                      "Question::BowTie",
                      "Question::DragAndDrop",
                      "Question::Matching",
                      "Question::SelectAllThatApply",
                      "Question::StimulusCaseStudy",
                      "Question::Traditional"
                    ])
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.filter' do
    it 'omits children of question aggregation' do
      FactoryBot.create(:question_matching, child_of_aggregation: true)
      expect(described_class.filter).to eq([])
    end

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'filters by keyword' do
      # Why this one large test instead of many smaller tests?  Because the setup cost for the state
      # of the data is noticable.  In other words, by running multiple tests with one setup
      # (e.g. the below creation of questions, keywords, and categories) we don't have to pay a
      # setup cost for each individual test.
      question1 = FactoryBot.create(:question_matching)
      question2 = FactoryBot.create(:question_drag_and_drop)
      question3 = FactoryBot.create(:question_select_all_that_apply)
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

      # When given a type it filters to only that type
      expect(described_class.filter(type: question1.model_name.name)).to eq([question1])

      # When given a type and categories that don't overlap
      expect(described_class.filter(type: question1.model_name.name, keywords: [keyword2.name])).to eq([])
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end
end

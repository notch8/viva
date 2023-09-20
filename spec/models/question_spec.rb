# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Question, type: :model do
  # The base Question instance should never be valid; we want to specify the correct type.
  it_behaves_like "a Question", valid: false, test_type_name_to_class: false

  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Question") }

  describe '.descendants' do
    subject { described_class.descendants }

    # rubocop:disable RSpec/ExampleLength
    it do
      is_expected.to(
        match_array([Question::BowTie,
                     Question::Scenario,
                     Question::DragAndDrop,
                     Question::Matching,
                     Question::SelectAllThatApply,
                     Question::StimulusCaseStudy,
                     Question::Traditional])
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.build_from_csv_row' do
    subject { described_class.build_from_csv_row(row) }

    context 'when no row TYPE is provided' do
      let(:row) { CsvRow.new('IMPORT_ID' => '1') }

      it { is_expected.to be_a(Question::NoType) }
      it { is_expected.not_to be_valid }
    end
    context 'when no row IMPORT_ID is provided' do
      let(:row) { CsvRow.new('TYPE' => 'Traditional') }

      it { is_expected.to be_a(Question::NoImportId) }
      it { is_expected.not_to be_valid }
    end
    context "when row's TYPE is not one of the Question.descendants" do
      let(:row) { CsvRow.new('IMPORT_ID' => '1', 'TYPE' => 'Extra Spicy') }

      it { is_expected.to be_a(Question::InvalidType) }
      it { is_expected.not_to be_valid }
    end
  end

  describe '.build_row' do
    it 'should be implemented by subclasses' do
      expect { described_class.build_row }.to raise_error(NotImplementedError)
    end
  end

  describe '.type_name' do
    subject { described_class.type_names }

    # rubocop:disable RSpec/ExampleLength
    it do
      is_expected.to(
        match_array([
                      "Bow Tie",
                      "Drag and Drop",
                      "Matching",
                      "Select All That Apply",
                      "Stimulus Case Study",
                      "Traditional"
                    ])
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.filter_as_json' do
    # rubocop:disable RSpec/ExampleLength
    it 'includes keyword_names and category_names' do
      question1 = FactoryBot.create(:question_matching, :with_keywords, :with_categories)

      results = described_class.filter_as_json

      expect(results).to(
        eq([{ id: question1.id,
              text: question1.text,
              type_name: question1.type_name,
              type: question1.type,
              type_label: question1.type_label,
              level: question1.level,
              data: question1.data,
              keyword_names: question1.keywords.map(&:name),
              category_names: question1.categories.map(&:name) }.stringify_keys])
      )
    end
    # rubocop:enable RSpec/ExampleLength

    context 'when questions have no keywords' do
      it 'has an empty array for keyword_names' do
        question = FactoryBot.create(:question_matching)
        expect(question.keywords).to be_empty

        results = described_class.filter_as_json

        expect(results.first.fetch("keyword_names")).to eq([])
      end
    end

    context 'when questions have no categories' do
      it 'has an empty array for category_names' do
        question = FactoryBot.create(:question_matching)
        expect(question.categories).to be_empty

        results = described_class.filter_as_json

        expect(results.first.fetch("category_names")).to eq([])
      end
    end
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
      expect(described_class.filter(type_name: question1.type_name)).to eq([question1])

      # When given a type and categories that don't overlap
      expect(described_class.filter(type_name: question1.type_name, keywords: [keyword2.name])).to eq([])
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable RSpec/MultipleExpectations
  end
end

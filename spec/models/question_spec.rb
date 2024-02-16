# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Question, type: :model do
  # The base Question instance should never be valid; we want to specify the correct type.
  it_behaves_like "a Question", valid: false, test_type_name_to_class: false

  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Question") }
  its(:required_csv_headers) { is_expected.to eq(%w[IMPORT_ID TEXT TYPE]) }
  its(:export_as_xml) { is_expected.to eq(false) }
  it { is_expected.not_to have_parts }

  describe '.descendants' do
    subject { described_class.descendants }

    # rubocop:disable RSpec/ExampleLength
    it do
      is_expected.to(
        match_array([Question::BowTie,
                     Question::Categorization,
                     Question::Scenario,
                     Question::DragAndDrop,
                     Question::Essay,
                     Question::Matching,
                     Question::SelectAllThatApply,
                     Question::StimulusCaseStudy,
                     Question::Traditional,
                     Question::Upload])
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.extract_subject_names_from' do
    let(:row) do
      CsvRow.new("SUBJECT" => "a", "SUBJECTS" => "A,b", "SUBJECT_1" => "c,d", "SUBJECT_2" => "a,E,f")
    end
    subject { described_class.extract_subject_names_from(row) }

    it "downcases and sets unique entries" do
      expect(subject).to match_array(%w[a b c d e f])
    end
  end

  describe '.extract_keyword_names_from' do
    let(:row) do
      CsvRow.new("KEYWORD" => "a", "KEYWORDS" => "A,b", "KEYWORD_1" => "c,d", "KEYWORD_2" => "a,E,f")
    end
    subject { described_class.extract_keyword_names_from(row) }

    it "downcases and sets unique entries" do
      expect(subject).to match_array(%w[a b c d e f])
    end
  end

  describe '.build_from_csv_row' do
    subject { described_class.build_from_csv_row(row:, questions: {}) }

    context 'when no row TYPE is provided' do
      let(:row) { CsvRow.new('IMPORT_ID' => '1') }

      it { is_expected.to be_a(Question::NoType) }
      it { is_expected.not_to be_valid }
    end
    context "when row's TYPE is not one of the Question.descendants" do
      let(:row) { CsvRow.new('IMPORT_ID' => '1', 'TYPE' => 'Extra Spicy') }

      it { is_expected.to be_a(Question::InvalidType) }
      it { is_expected.not_to be_valid }
    end
  end

  describe '.invalid_question_due_to_missing_headers' do
    subject { described_class.invalid_question_due_to_missing_headers(row:) }
    let(:row) { CsvRow.new(values) }

    context 'when given a row with valid headers' do
      let(:values) { described_class.required_csv_headers.index_with { |key| "Value of #{key}" } }
      it { is_expected.to be_nil }
    end

    context 'when given a row with invalid headers' do
      let(:values) { {} }
      it { is_expected.to be_a(Question::ExpectedColumnMissing) }
    end
  end

  describe '.type_name' do
    subject { described_class.type_names }

    # rubocop:disable RSpec/ExampleLength
    it do
      is_expected.to(
        match_array([
                      "Bow Tie",
                      "Categorization",
                      "Drag and Drop",
                      "Essay",
                      "Matching",
                      "Select All That Apply",
                      "Stimulus Case Study",
                      "Traditional",
                      "Upload"
                    ])
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '.filter_as_json' do
    # rubocop:disable RSpec/ExampleLength
    it 'includes keyword_names and subject_names' do
      question1 = FactoryBot.create(:question_matching, :with_keywords, :with_subjects)

      results = described_class.filter_as_json

      expect(results).to(
        eq([{ id: question1.id,
              text: question1.text,
              type_name: question1.type_name,
              type: question1.type,
              type_label: question1.type_label,
              level: question1.level,
              data: question1.data,
              keyword_names: question1.keywords.names,
              subject_names: question1.subjects.names }.stringify_keys])
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

    context 'when questions have no subjects' do
      it 'has an empty array for subject_names' do
        question = FactoryBot.create(:question_matching)
        expect(question.subjects).to be_empty

        results = described_class.filter_as_json

        expect(results.first.fetch("subject_names")).to eq([])
      end
    end
  end

  describe '.filter' do
    it 'omits children of question aggregation' do
      FactoryBot.create(:question_matching, child_of_aggregation: true)
      expect(described_class.filter).to eq([])
    end

    # rubocop:disable RSpec/ExampleLength
    it 'filters by keyword' do
      # Why this one large test instead of many smaller tests?  Because the setup cost for the state
      # of the data is noticable.  In other words, by running multiple tests with one setup
      # (e.g. the below creation of questions, keywords, and subjects) we don't have to pay a
      # setup cost for each individual test.
      question1 = FactoryBot.create(:question_matching)
      question2 = FactoryBot.create(:question_drag_and_drop)
      question3 = FactoryBot.create(:question_select_all_that_apply)
      keyword1 = FactoryBot.create(:keyword)
      keyword2 = FactoryBot.create(:keyword)
      keyword3 = FactoryBot.create(:keyword)
      subject1 = FactoryBot.create(:subject)
      subject2 = FactoryBot.create(:subject)
      subject3 = FactoryBot.create(:subject)
      question1.keywords << keyword1
      question1.subjects << subject1
      question2.keywords << keyword2
      question2.keywords << keyword3
      question2.subjects << subject2
      question2.subjects << subject3
      question3.subjects << subject3
      question3.keywords << keyword3

      expect(described_class.filter).to eq([question1, question2, question3])

      expect(described_class.filter(keywords: [keyword1.name])).to eq([question1])
      expect(described_class.filter(keywords: [keyword2.name])).to eq([question2])

      # Demonstrating that we "and together" keywords
      expect(described_class.filter(keywords: [keyword1.name, keyword2.name])).to eq([])

      expect(described_class.filter(keywords: [keyword2.name, keyword3.name])).to eq([question2])

      expect(described_class.filter(keywords: [keyword1.name, keyword3.name])).to eq([])

      # When we mix a subject in with a keyword
      expect(described_class.filter(keywords: [keyword1.name, subject1.name])).to eq([])

      # When we mix a keyword with a subject
      expect(described_class.filter(subjects: [keyword1.name, subject1.name])).to eq([])

      # When we query only the subject
      expect(described_class.filter(subjects: [subject1.name])).to eq([question1])

      # When we provide both subject and keyword
      expect(described_class.filter(subjects: [subject1.name], keywords: [keyword1.name])).to eq([question1])

      # When nothing meets the criteria
      expect(described_class.filter(subjects: [subject1.name], keywords: [keyword2.name])).to eq([])

      # When given a type it filters to only that type
      expect(described_class.filter(type_name: question1.type_name)).to eq([question1])
      expect(described_class.filter(type_name: [question1.type_name, question2.type_name])).to eq([question1, question2])

      # When given a type and subjects that don't overlap
      expect(described_class.filter(type_name: question1.type_name, keywords: [keyword2.name])).to eq([])
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#errors' do
    subject { described_class.new }

    # This spec verifies the interface of the Question#errors#to_hash
    it 'is a Hash<Symbol,Array<String>> data structure' do
      expect(subject).not_to be_valid

      expect(subject.errors.to_hash[:text]).to be_a(Array)
    end
  end
end

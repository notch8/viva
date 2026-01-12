# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Question, type: :model do
  # The base Question instance should never be valid; we want to specify the correct type.
  it_behaves_like "a Question", valid: false, test_type_name_to_class: false

  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Question") }
  its(:required_csv_headers) { is_expected.to eq(%w[IMPORT_ID TEXT TYPE]) }
  its(:canvas_export_type) { is_expected.to eq(false) }
  it { is_expected.not_to have_parts }
  it { should have_many(:bookmarks).dependent(:destroy) }

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

  describe '.build_from_csv_row' do
    let(:user) { create(:user) }
    subject { described_class.build_from_csv_row(row:, questions: {}, user_id: user.id) }

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
    context "when row's SUBJECT is not in table Subject" do
      let(:row) { CsvRow.new('IMPORT_ID' => '1', 'TYPE' => 'Essay', 'SUBJECT' => searched_subject) }
      let(:searched_subject) { 'France' }
      let!(:setting_names_array) do
        subjects_data = YAML.load_file('spec/fixtures/files/valid_subjects.yaml')
        subjects_data['subjects']['name']
      end
      let(:found_subject) { setting_names_array.include?(searched_subject) ? searched_subject : nil }

      before do
        allow(Subject).to receive(:find_by).with(name: searched_subject).and_return(found_subject)
      end

      it { is_expected.to be_a(Question::InvalidSubject) }
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
                      "Multiple Choice",
                      "Select All That Apply",
                      "Stimulus Case Study",
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
              subject_names: question1.subjects.names,
              images: [],
              alt_texts: [],
              user_id: question1.user_id,
              hashid: question1.hashid }.stringify_keys])
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

      # Demonstrating that we "OR together" keywords
      expect(described_class.filter(keywords: [keyword1.name, keyword2.name])).to match_array([question1, question2])

      # Demonstrating that we "OR together" subjects
      expect(described_class.filter(subjects: [subject1.name, subject2.name])).to match_array([question1, question2])

      # When we mix a subject in with a keyword
      expect(described_class.filter(keywords: [keyword1.name, subject1.name])).to eq([question1])

      # When we mix a keyword with a subject
      expect(described_class.filter(subjects: [keyword1.name, subject1.name])).to eq([question1])

      # When we query only the subject
      expect(described_class.filter(subjects: [subject1.name])).to eq([question1])

      # When we provide both subject and keyword
      expect(described_class.filter(subjects: [subject1.name], keywords: [keyword1.name])).to eq([question1])

      # When we provide a subject for one question and a keyword for another
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

  describe '#searchable' do
    let(:user) { create(:user) }
    context 'when data is a hash with html as the value' do
      subject do
        Question::Upload.create(
          text: 'Describe the impact of Studio Ghibli on anime.',
          user_id: user.id,
          data: { 'html' => '<p>Consider films like Spirited Away and Princess Mononoke.</p><ul><li>Cultural significance</li><li>Link to <a href="https://ghibli.jp">Studio Ghibli</a></li></ul>' }
        )
      end
      it 'indexes the data field onto the searchable field as a string' do
        expect(subject.searchable).to eq 'consider films like spirited away and princess mononoke cultural significance link to studio ghibli'
      end

      it 'is searchable with #search' do
        expect(Question.search('spirited away')).to eq [subject]
      end

      it 'is stemmed' do
        expect(Question.search('spirit')).to eq [subject]
      end
    end

    context 'when data is an array' do
      subject do
        Question::Traditional.create(
          text: 'Which of these is a famous anime director?',
          user_id: user.id,
          data: [
            { 'answer' => 'Hayao Miyazaki', 'correct' => true },
            { 'answer' => 'Christopher Nolan', 'correct' => false },
            { 'answer' => 'Martin Scorsese', 'correct' => false },
            { 'answer' => 'Quentin Tarantino', 'correct' => false }
          ]
        )
      end
      it 'indexes the data field onto the searchable field as a string' do
        expect(subject.searchable).to eq 'hayao miyazaki christopher nolan martin scorsese quentin tarantino'
        expect(Question.search('Miyazaki')).to eq [subject]
      end
    end

    context 'when the quetion is a stimulus case study' do
      before do
        allow(subject).to receive(:child_questions).and_return(child_questions)

        subject.save
      end

      subject do
        Question::StimulusCaseStudy.new(
          text: 'Analysis of Attack on Titan themes and symbolism.',
          user_id: user.id
        )
      end

      let(:child_questions) do
        [
          Question::Scenario.new(
            text: 'Read the following excerpt about the walls in Attack on Titan.',
            user_id: user.id
          ),
          Question::Categorization.new(
            text: 'Match the Titan types with their characteristics.',
            user_id: user.id,
            data: [
              { "answer" => "Founding Titan", "correct" => ["Controls other titans", "Memory manipulation"] },
              { "answer" => "Armored Titan", "correct" => ["Hardened body", "Enhanced durability"] },
              { "answer" => "Colossal Titan", "correct" => ["Massive size", "Steam emission"] },
              { "answer" => "Attack Titan", "correct" => ["Future memory access", "Enhanced strength"] }
            ]
          ),
          Question::DragAndDrop.new(
            text: 'Order the following events chronologically.',
            user_id: user.id,
            data: [
              { "answer" => "Fall of Wall Maria", "correct" => true },
              { "answer" => "Battle of Trost", "correct" => true },
              { "answer" => "Female Titan arc", "correct" => true },
              { "answer" => "Return to Shiganshina", "correct" => true }
            ]
          ),
          Question::Essay.new(
            text: 'Analyze the symbolism of walls in the series.',
            user_id: user.id,
            data: { "html" => "<p>Consider the following aspects:</p><ul><li>Physical protection</li><li>Symbolic imprisonment</li><li>Link to <a href='https://attackontitan.com'>Official Site</a></li></ul>" }
          )
        ]
      end

      it 'indexes the child questions\' data field(s) onto the searchable field of the parent as a string' do
        # rubocop:disable Layout/LineLength
        expected_text = 'read the following excerpt about the walls in attack on titan match the titan types with their characteristics order the following events chronologically analyze the symbolism of walls in the series founding titan controls other titans memory manipulation armored titan hardened body enhanced durability colossal titan massive size steam emission attack titan future memory access enhanced strength fall of wall maria battle of trost female titan arc return to shiganshina consider the following aspects physical protection symbolic imprisonment link to official site'
        # rubocop:enable Layout/LineLength
        expect(subject.searchable).to eq expected_text
        expect(Question.search('titan')).to eq [subject]
      end
    end
  end
end

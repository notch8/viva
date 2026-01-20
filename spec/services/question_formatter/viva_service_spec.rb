# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::VivaService do
  let(:bowtie_question) do
    build(:question_bow_tie,
      text: 'Sample bow tie question',
      data: {
        'center' => {
          'label' => 'Center Label',
          'answers' => [
            { 'answer' => 'Center Answer 1', 'correct' => true },
            { 'answer' => 'Center Answer 2', 'correct' => false }
          ]
        },
        'left' => {
          'label' => 'Left Label',
          'answers' => [
            { 'answer' => 'Left Answer 1', 'correct' => true },
            { 'answer' => 'Left Answer 2', 'correct' => false }
          ]
        },
        'right' => {
          'label' => 'Right Label',
          'answers' => [
            { 'answer' => 'Right Answer 1', 'correct' => true },
            { 'answer' => 'Right Answer 2', 'correct' => false }
          ]
        }
      })
  end
  # rubocop:disable Layout/LineLength
  let(:formatted_bowtie_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,CENTER_LABEL,CENTER_1,CENTER_2,CENTER_CORRECT_ANSWERS,LEFT_LABEL,LEFT_1,LEFT_2,LEFT_CORRECT_ANSWERS,RIGHT_LABEL,RIGHT_1,RIGHT_2,RIGHT_CORRECT_ANSWERS\n,Bow Tie,Sample bow tie question,,Center Label,Center Answer 1,Center Answer 2,1,Left Label,Left Answer 1,Left Answer 2,1,Right Label,Right Answer 1,Right Answer 2,1\n"
  end
  # rubocop:enable Layout/LineLength
  let(:categorization_question) do
    build(:question_categorization,
      text: 'Sample categorization',
      data: [
        { 'answer' => 'Category 1', 'correct' => ['Item 1', 'Item 2'] },
        { 'answer' => 'Category 2', 'correct' => ['Item 3'] }
      ])
  end
  let(:formatted_categorization_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,LEFT_1,RIGHT_1,LEFT_2,RIGHT_2\n,Categorization,Sample categorization,,Category 1,\"Item 1, Item 2\",Category 2,Item 3\n"
  end
  let(:drag_and_drop_question) do
    build(:question_drag_and_drop,
      text: 'Sample drag and drop question',
      data: [
        { 'answer' => 'Item 1', 'correct' => true },
        { 'answer' => 'Item 2', 'correct' => false },
        { 'answer' => 'Item 3', 'correct' => true }
      ])
  end
  let(:formatted_drag_and_drop_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n,Drag and Drop,Sample drag and drop question,,\"1,3\",Item 1,Item 2,Item 3\n"
  end
  let(:essay_question) do
    build(:question_essay,
      text: 'Sample essay question',
      data: { 'html' => '<p>Essay prompt</p><ul><li>Point 1</li></ul><a href="https://example.com">Link</a>' })
  end
  let(:formatted_essay_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,TEXT_1,TEXT_2,TEXT_3\n,Essay,Sample essay question,,<p>Essay prompt</p>,<ul><li>Point 1</li></ul>,\"<a href=\"\"https://example.com\"\">Link</a>\"\n"
  end
  let(:matching_question) do
    build(:question_matching,
      text: 'Sample matching question',
      data: [
        {
          'answer' => 'Term 1',
          'correct' => ['Definition 1']
        },
        {
          'answer' => 'Term 2',
          'correct' => ['Definition 2']
        },
        {
          'answer' => 'Term 3',
          'correct' => ['Definition 3']
        }
      ])
  end
  let(:formatted_matching_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,LEFT_1,RIGHT_1,LEFT_2,RIGHT_2,LEFT_3,RIGHT_3\n,Matching,Sample matching question,,Term 1,Definition 1,Term 2,Definition 2,Term 3,Definition 3\n"
  end
  let(:traditional_question) do
    build(:question_traditional,
      text: 'Sample multiple choice',
      data: [
        { 'answer' => 'Option A', 'correct' => true },
        { 'answer' => 'Option B', 'correct' => false }
      ])
  end
  let(:formatted_traditional_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,CORRECT_ANSWERS,ANSWER_1,ANSWER_2\n,Multiple Choice,Sample multiple choice,,1,Option A,Option B\n"
  end
  let(:sata_question) do
    build(:question_select_all_that_apply,
      text: 'Sample select all question',
      data: [
        { 'answer' => 'Option A', 'correct' => true },
        { 'answer' => 'Option B', 'correct' => true },
        { 'answer' => 'Option C', 'correct' => false }
      ])
  end
  let(:formatted_sata_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n,Select All That Apply,Sample select all question,,\"1,2\",Option A,Option B,Option C\n"
  end
  let(:scenario) { build(:question_scenario, text: 'Sample scenario') }
  let(:sub_question_essay) { build(:question_essay, text: 'Sub question', data: { 'html' => '<p>Essay prompt</p>' }) }
  let(:sub_question_mc) do
    build(:question_traditional,
      text: 'Multiple choice sub question',
      data: [
        { 'answer' => 'Option A', 'correct' => true },
        { 'answer' => 'Option B', 'correct' => false }
      ])
  end
  let(:stimulus_case_study_question) do
    build(:question_stimulus_case_study,
      text: 'Main question',
      child_questions: [scenario, sub_question_essay, sub_question_mc])
  end
  # rubocop:disable Layout/LineLength
  let(:formatted_stimulus_case_study_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,PART_OF,PRESENTATION_ORDER,TEXT_1,CORRECT_ANSWERS,ANSWER_1,ANSWER_2\n,Stimulus Case Study,Main question,,,,,,,\n,Scenario,Sample scenario,,,0,,,,\n,Essay,Sub question,,,1,<p>Essay prompt</p>,,,\n,Multiple Choice,Multiple choice sub question,,,2,,1,Option A,Option B\n"
  end
  # rubocop:enable Layout/LineLength
  let(:upload_question) do
    build(:question_upload,
      text: 'Sample upload question',
      data: { 'html' => '<p>Upload instructions</p><ul><li>File type: PDF</li></ul><a href="https://example.com">Guidelines</a>' })
  end
  let(:formatted_upload_question) do
    "IMPORT_ID,TYPE,TEXT,LEVEL,TEXT_1,TEXT_2,TEXT_3\n,Upload,Sample upload question,,<p>Upload instructions</p>,<ul><li>File type: PDF</li></ul>,\"<a href=\"\"https://example.com\"\">Guidelines</a>\"\n"
  end

  describe '#format_content' do
    describe 'handles all question types' do
      it 'handles bow tie questions' do
        zip_file = described_class.new([bowtie_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_bowtie_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles categorization questions' do
        zip_file = described_class.new([categorization_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_categorization_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles drag and drop questions' do
        zip_file = described_class.new([drag_and_drop_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_drag_and_drop_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles essays' do
        zip_file = described_class.new([essay_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_essay_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles matching' do
        zip_file = described_class.new([matching_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_matching_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles traditional multiple choice' do
        zip_file = described_class.new([traditional_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_traditional_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles select all that apply' do
        zip_file = described_class.new([sata_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_sata_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles stimulus case study' do
        zip_file = described_class.new([stimulus_case_study_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_stimulus_case_study_question)
          expect(content).to be_a(String)
        end
      end

      it 'handles uploads' do
        zip_file = described_class.new([upload_question]).format_content
        Zip::File.open(zip_file.path) do |zip_entries|
          content = zip_entries.get_input_stream('viva_questions.csv').read
          expect(content).to eq(formatted_upload_question)
          expect(content).to be_a(String)
        end
      end
    end
  end

  describe 'with images' do
    let(:traditional_question) do
      create(:question_traditional, :with_images)
    end

    it 'includes the image URL' do
      zip_file = described_class.new([traditional_question]).format_content
      Zip::File.open(zip_file.path) do |zip_entries|
        expect(zip_entries.map(&:name).any? { |name| name.include?('images') }).to eq true
      end
    end
  end

  describe 'roundtripping' do
    subject { Question::ImporterCsv.from_file(viva_questions_file, user_id: user.id) }
    let(:user) { create(:user) }
    let(:questions) do
      [bowtie_question, categorization_question, drag_and_drop_question, essay_question, matching_question, traditional_question, sata_question, upload_question, stimulus_case_study_question]
    end
    let(:viva_questions_file) { described_class.new(questions).format_content }

    before do
      questions.each(&:save!)
    end

    it 'reimports correctly' do
      # 9 questions within questions array, plus 3 stimulus case study subquestions
      expect { subject.save }.to change(Question, :count).by(12)
    end
  end
end

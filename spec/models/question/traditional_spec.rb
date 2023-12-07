# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Traditional do
  it_behaves_like "a Question", export_as_xml: true
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Traditional") }

  describe '.build_row' do
    subject { described_class.build_row(row: data, questions: {}) }

    [
      [{ "ANSWERS" => "2", "ANSWER_1" => "Hello World!" }, /ANSWERS column indicates that ANSWER_2/],
      [{ "ANSWERS" => "1,2", "ANSWER_1" => "A1", "ANSWER_2" => "A2" }, /expected ANSWERS cell to have one correct answer/],
      [{ "ANSWER_1" => "A1", "ANSWER_2" => "A2" }, /expected ANSWERS cell to have one correct answer/]
    ].each do |given_data, error_message|
      context "with invalid data #{given_data.inspect}" do
        let(:data) { CsvRow.new(given_data) }

        it "will not call the underlying question's save!" do
          expect(subject.question).not_to receive(:save!)
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid, error_message)
        end
      end
    end

    context 'with valid data' do
      let(:data) do
        CsvRow.new("IMPORT_ID" => "123456",
                   "TYPE" => "Traditional",
                   "TEXT" => "Which one is true?",
                   "LEVEL" => Level.names.first,
                   "ANSWERS" => "1",
                   "ANSWER_1" => "true",
                   "ANSWER_2" => "false",
                   "ANSWER_3" => "",
                   "SUBJECTS" => "True/False, Amazing",
                   "SUBJECT_1" => "Fun Question",
                   "SUBJECT" => "Hard Question",
                   "KEYWORDS" => "Red",
                   "KEYWORD_1" => "Green",
                   "KEYWORD_2" => "Orange",
                   "KEYWORD" => "Yellow")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) { is_expected.to eq([{ "answer" => "true", "correct" => true }, { "answer" => "false", "correct" => false }]) }
      its(:level) { is_expected.to eq(Level.names.first) }

      describe 'once saved' do
        before do
          subject.save
          subject.reload
        end

        its(:keyword_names) { is_expected.to match_array(["Green", "Orange", "Red", "Yellow"]) }
        its(:subject_names) { is_expected.to match_array(["Amazing", "Fun Question", "Hard Question", "True/False"]) }
      end
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build(:question_traditional, data:) }
    [
      [[{ answer: "Green" }, { answer: "Blue", corret: false }], false],
      [[{ answer: "A", correct: true }, { answer: "B", correct: false }, { answer: "C", correct: false }], true],
      # The last element for each pair must be a boolean
      [[{ answer: "A", correct: true }, { answer: "B", correct: false }, { answer: "C", correct: nil }], false],
      # Disallow more than one correct answer
      [[{ answer: "A", correct: true }, { answer: "B", correct: true }, { answer: "C", correct: false }], false],
      [nil, false],
      [[], false],
      ["", false],
      [{}, false],
      # We have a triple and a single.
      [[{ answer: "Green", correct: true, else: "Yellow" }, { answer: "t" }], false],
      # We have two pairs, which should be valid.
      [[{ answer: "A", correct: true }, { answer: "B", correct: false }], true],
      [[{ answer: "Green", correct: false }, { answer: "Blue", correct: false }], false],
      [[{ answer: "Green", correct: false }, { answer: "Blue", correct: true }], true]
    ].each do |given, valid|
      context "when given #{given.inspect}" do
        let(:data) { given }

        if valid
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe 'QTI Export' do
    describe '#correct_response_index' do
      subject { FactoryBot.build(:question_traditional, data:).correct_response_index }
      [
        [[{ answer: "Green", correct: false }, { answer: "Blue", correct: true }], 1]
      ].each do |given_data, expected_correct_response_index|
        context "with #{given_data}" do
          let(:data) { given_data }

          it { is_expected.to eq(expected_correct_response_index) }
        end
      end
    end

    describe "#with_each_choice_index_and_label" do
      subject { FactoryBot.build(:question_traditional, data: [{ answer: "Green", correct: false }, { answer: "Blue", correct: true }]) }

      it 'yields the index and answer pair' do
        expect { |b| subject.with_each_choice_index_and_label(&b) }.to yield_successive_args([0, "Green"], [1, "Blue"])
      end
    end
  end
end

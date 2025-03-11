# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::SelectAllThatApply do
  it_behaves_like "a Question", canvas_export_type: true
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Select All That Apply") }

  describe "ImportCsvRow inner_class" do
    describe 'save!' do
      subject { described_class::ImportCsvRow.new(row: data, question_type: described_class, questions: {}) }

      context 'when inner_class is invalid' do
      end
    end
  end

  describe '.build_row' do
    subject { described_class.build_row(row:, questions: {}) }
    [
      [{ "CORRECT_ANSWERS" => "2,4,6", "ANSWER_1" => "A1", "ANSWER_3" => "A3" },
       /CORRECT_ANSWERS column indicates that ANSWER_2, ANSWER_4, ANSWER_6/],
      [{ "ANSWER_1" => "A1" }, /expected CORRECT_ANSWERS column/]
    ].each do |given_data, error_message|
      context "with invalid data #{given_data.inspect}" do
        let(:row) { CsvRow.new(given_data) }

        it "will not call the underlying question's save!" do
          expect(subject.question).not_to receive(:save!)
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid, error_message)
        end
      end
    end

    context 'with valid data' do
      let(:row) do
        CsvRow.new("TYPE" => "AllThatApply",
                   "TEXT" => "Which one is affirmative?",
                   "LEVEL" => Level.names.first,
                   "CORRECT_ANSWERS" => "1, 3",
                   "ANSWER_1" => "true",
                   "ANSWER_2" => "false",
                   "ANSWER_3" => "yes",
                   "ANSWER_4" => "",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) { is_expected.to eq([{ 'answer' => "true", 'correct' => true }, { 'answer' => "false", 'correct' => false }, { 'answer' => "yes", 'correct' => true }]) }

      context 'when saved' do
        before { subject.save }

        its(:keyword_names) { is_expected.to match_array(["One", "Two"]) }
        its(:subject_names) { is_expected.to match_array(["Big", "Little"]) }
        its(:level) { is_expected.to eq(Level.names.first) }
      end
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build(:question_select_all_that_apply, data:) }
    [
      [[{ answer: "Green" }, { answer: "Blue", correct: false }], false],
      [[{ answer: "A", correct: true }, { answer: "B", correct: true }, { answer: "C", correct: false }], true],
      [nil, false],
      ["", false],
      [[], false],
      # We have a triple and a single.
      # We have two pairs, which should be valid.
      [[{ answer: "Green", correct: true, else: "Yellow" }], false],
      [[{ answer: "A", correct: true }, { answer: "B", correct: false }], true],
      [[{ answer: "Green", correct: false }, { answer: "Blue", correct: false }], false]
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
    describe "#with_each_choice_index_label_and_correctness" do
      subject { FactoryBot.build(:question_select_all_that_apply, data: [{ answer: "Green", correct: false }, { answer: "Blue", correct: true }]) }

      it 'yields the index and answer pair' do
        expect { |b| subject.with_each_choice_index_label_and_correctness(&b) }.to yield_successive_args([0, "Green", false], [1, "Blue", true])
      end
    end
  end
end

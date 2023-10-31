# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::SelectAllThatApply do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Select All That Apply") }

  describe "ImportCsvRow inner_class" do
    describe 'save!' do
      subject { described_class::ImportCsvRow.new(row: data, question_type: described_class) }

      context 'when inner_class is invalid' do
        let(:data) do
          CsvRow.new("ANSWERS" => "2,4,6",
                     "ANSWER_1" => "Hello World!",
                     "ANSWER_3" => "Something",
                     "ANSWER_5" => "Else")
        end

        it "will not call the underlying question's save!" do
          expect(subject.question).not_to receive(:save!)
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid, /ANSWERS column indicates that ANSWER_2, ANSWER_4, ANSWER_6/)
        end
      end
    end
  end

  describe '.build_row' do
    subject { described_class.build_row(row) }
    let(:row) do
      CsvRow.new("TYPE" => "AllThatApply",
                 "TEXT" => "Which one is affirmative?",
                 "LEVEL" => Level.names.first,
                 "ANSWERS" => "1, 3",
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
end

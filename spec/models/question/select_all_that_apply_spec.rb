# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::SelectAllThatApply do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Select All That Apply") }

  describe '.import_csv_row' do
    let(:data) do
      CsvRow.new("TYPE" => "AllThatApply",
                 "TEXT" => "Which one is affirmative?",
                 "ANSWERS" => "1, 3",
                 "ANSWER_1" => "true",
                 "ANSWER_2" => "false",
                 "ANSWER_3" => "yes")
    end

    it "creates a Traditional question" do
      allow(data).to receive(:headers).and_return(data.keys)
      expect do
        described_class.import_csv_row(data)
      end.to change(described_class, :count).by(1)

      expect(described_class.last.data).to eq([{ 'answer' => "true", 'correct' => true }, { 'answer' => "false", 'correct' => false }, { 'answer' => "yes", 'correct' => true }])
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

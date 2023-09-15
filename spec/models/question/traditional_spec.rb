# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Traditional do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Traditional") }

  describe '.import_csv_row' do
    let(:data) do
      CsvRow.new("TYPE" => "Traditional",
                 "TEXT" => "Which one is true?",
                 "ANSWERS" => "1",
                 "ANSWER_1" => "true",
                 "ANSWER_2" => "false")
    end

    it "creates a Traditional question" do
      allow(data).to receive(:headers).and_return(data.keys)
      expect do
        described_class.import_csv_row(data)
      end.to change(Question::Traditional, :count).by(1)

      expect(described_class.last.data).to eq([{ "answer" => "true", "correct" => true }, { "answer" => "false", "correct" => false }])
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
end

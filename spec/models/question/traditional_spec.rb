# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Traditional do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Traditional") }

  describe '.build_row' do
    subject { described_class.build_row(data) }
    let(:data) do
      CsvRow.new("IMPORT_ID" => "123456",
                 "TYPE" => "Traditional",
                 "TEXT" => "Which one is true?",
                 "ANSWERS" => "1",
                 "ANSWER_1" => "true",
                 "ANSWER_2" => "false",
                 "CATEGORIES" => "True/False, Amazing",
                 "CATEGORY_1" => "Fun Question",
                 "CATEGORY" => "Hard Question",
                 "KEYWORDS" => "Red",
                 "KEYWORD_1" => "Green",
                 "KEYWORD_2" => "Orange",
                 "KEYWORD" => "Yellow")
    end

    it { is_expected.to be_valid }
    it { is_expected.not_to be_persisted }
    its(:data) { is_expected.to eq([{ "answer" => "true", "correct" => true }, { "answer" => "false", "correct" => false }]) }

    describe 'once saved' do
      before do
        subject.save
        subject.reload
      end

      its(:keyword_names) { is_expected.to match_array(["Green", "Orange", "Red", "Yellow"]) }
      its(:category_names) { is_expected.to match_array(["Amazing", "Fun Question", "Hard Question", "True/False"]) }
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

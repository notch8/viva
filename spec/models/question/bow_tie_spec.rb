# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::BowTie do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Bow Tie") }

  describe '.build_row' do
    subject { described_class.build_row(row: data, questions: {}) }

    let(:base_line_data) do
      {
        "TYPE" => described_class.type_name,
        "TEXT" => "Lifecycle of chemicals.",
        "LEVEL" => Level.names.first,
        "SUBJECTS" => "True/False, Amazing",
        "KEYWORDS" => "Red"
      }
    end

    [
      [{ "CENTER_LABEL" => "Center", "CENTER_1" => "...hello..." },
       /missing LEFT_LABEL, RIGHT_LABEL/],
      [{ "CENTER_LABEL" => "C", "RIGHT_LABEL" => "R", "LEFT_LABEL" => "L" },
       /missing CENTER_CORRECT_ANSWERS, LEFT_CORRECT_ANSWERS, RIGHT_CORRECT_ANSWERS/],
      [{ "CENTER_LABEL" => "C", "RIGHT_LABEL" => "R", "RIGHT_CORRECT_ANSWERS" => '1', "LEFT_LABEL" => "L" },
       /missing CENTER_CORRECT_ANSWERS, LEFT_CORRECT_ANSWERS/],
      [{ "RIGHT_LABEL" => "R", "RIGHT_CORRECT_ANSWERS" => 'R,r' },
       /RIGHT_CORRECT_ANSWERS should reference only RIGHT_\<INTEGER\> columns; instead got RIGHT_R, RIGHT_r/],
      [{ "CENTER_LABEL" => "C", "CENTER_CORRECT_ANSWERS" => '1', "RIGHT_LABEL" => "R", "RIGHT_CORRECT_ANSWERS" => '1', "LEFT_LABEL" => "L", 'LEFT_CORRECT_ANSWERS' => '1', 'LEFT_1' => 'Hello' },
       /expected columns CENTER_1 but was missing CENTER_1/]
    ].each do |given_data, message|
      context "with #{given_data.inspect}" do
        let(:data) { CsvRow.new(base_line_data.merge(given_data)) }
        it { is_expected.not_to be_valid }

        it "does not attempt to save" do
          expect(subject.question).not_to receive(:save!)
          expect { subject.save! }.to raise_error(message)
        end
      end
    end

    context 'with valid CSV row' do
      let(:data) do
        CsvRow.new("TYPE" => described_class.type_name,
                   "TEXT" => "Lifecycle of chemicals.",
                   "LEVEL" => Level.names.first,
                   "CENTER_LABEL" => "Center Label",
                   "CENTER_1" => "...when boiled becomes...",
                   "CENTER_2" => "...when eaten becomes...",
                   "CENTER_3" => "...when worn becomes...",
                   "CENTER_4" => "",
                   "CENTER_CORRECT_ANSWERS" => "1",
                   "LEFT_LABEL" => "Left Label",
                   "LEFT_1" => "Water",
                   "LEFT_2" => "Cabbage",
                   "LEFT_3" => "Shoe",
                   "LEFT_4" => "",
                   "LEFT_CORRECT_ANSWERS" => "1",
                   "RIGHT_LABEL" => "Right Label",
                   "RIGHT_1" => "Steam",
                   "RIGHT_2" => "Vapor",
                   "RIGHT_3" => "Rabbits",
                   "RIGHT_4" => "",
                   "RIGHT_CORRECT_ANSWERS" => "1,2",
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
      its(:data) do
        is_expected.to eq({ "center" => {
                              "label" => "Center Label",
                              "answers" => [{ "answer" => "...when boiled becomes...", "correct" => true },
                                            { "answer" => "...when eaten becomes...", "correct" => false },
                                            { "answer" => "...when worn becomes...", "correct" => false }]
                            },
                            "left" => {
                              "label" => "Left Label",
                              "answers" => [{ "answer" => "Water", "correct" => true },
                                            { "answer" => "Cabbage", "correct" => false },
                                            { "answer" => "Shoe", "correct" => false }]
                            },
                            "right" => {
                              "label" => "Right Label",
                              "answers" =>
                              [{ "answer" => "Steam", "correct" => true },
                               { "answer" => "Vapor", "correct" => true },
                               { "answer" => "Rabbits", "correct" => false }]
                            } })
      end

      describe 'once saved' do
        before do
          subject.save!
          subject.reload
        end

        its(:keyword_names) { is_expected.to match_array(["Green", "Orange", "Red", "Yellow"]) }
        its(:subject_names) { is_expected.to match_array(["Amazing", "Fun Question", "Hard Question", "True/False"]) }
        its(:level) { is_expected.to eq(Level.names.first) }
      end
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build(:question_bow_tie, data: given_data) }

    [
      [
        { center: { label: "The Label", answers: [{ answer: "To Select", correct: true }, { answer: "To Skip", correct: false }] },
          left: { label: "The Label", answers: [{ answer: "LCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
          right: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] } },
        true
      ], [
        { center: { label: "", answers: [{ answer: "To Select", correct: true }, { answer: "To Skip", correct: false }] },
          left: { label: "The Label", answers: [{ answer: "LCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
          right: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] } },
        false # Because center label is not present
      ], [
        { center: { label: "The Label", answers: [{ answer: "To Select", correct: true }, { answer: "To Skip", correct: true }] },
          left: { label: "The Label", answers: [{ answer: "LCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
          right: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] } },
        false # because the center has more than one true answer
      ], [
        { center: { label: "The Label", answers: [{ answer: "To Select", correct: true, else: true }, { answer: "To Skip", correct: false }] },
          left: { label: "The Label", answers: [{ answer: "LCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
          right: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] } },
        false # because we have a poorly formed center
      ], [
        nil, false
      ], [
        "", false
      ], [
        {}, false # because we don't have the proper keys
      ], [
        { center: { label: "The Label", answers: [{ answer: "To Select", correct: true }, { answer: "To Skip", correct: false }] },
          left: { label: "The Label", answers: [{ answer: "LCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
          right: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] },
          extraneous: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] } },
        false # because we have extra keys
      ], [
        { center: { label: "The Label", answers: [{ answer: "To Select", correct: false }, { answer: "To Skip", correct: false }] },
          left: [],
          right: { label: "The Label", answers: [{ answer: "RCorrect", correct: true }, { answer: "LIncorrect", correct: false }] } },
        false # because the left has entries
      ]
    ].each do |data, valid|
      context "when data is #{data.inspect}" do
        let(:given_data) { data }
        if valid
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

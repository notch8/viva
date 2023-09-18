# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::BowTie do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Bow Tie") }

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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::BowTie do
  it_behaves_like "a Question"

  describe 'data serialization' do
    subject { FactoryBot.build(:question_bow_tie, data: given_data) }

    [
      [
        { center: { label: "The Label", answers: [["To Select", true], ["To Skip", false]] },
          left: { label: "The Label", answers: [["LCorrect", true], ["LIncorrect", false]] },
          right: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] } },
        true
      ], [
        { center: { label: "", answers: [["To Select", true], ["To Skip", false]] },
          left: { label: "The Label", answers: [["LCorrect", true], ["LIncorrect", false]] },
          right: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] } },
        false # Because center label is not present
      ], [
        { center: { label: "The Label", answers: [["To Select", true], ["To Skip", true]] },
          left: { label: "The Label", answers: [["LCorrect", true], ["LIncorrect", false]] },
          right: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] } },
        false # because the center has more than one true answer
      ], [
        { center: { label: "The Label", answers: [["To Select", true, true], ["To Skip", false]] },
          left: { label: "The Label", answers: [["LCorrect", true], ["LIncorrect", false]] },
          right: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] } },
        false # because we have a poorly formed center
      ], [
        nil, false
      ], [
        "", false
      ], [
        {}, false # because we don't have the proper keys
      ], [
        { center: { label: "The Label", answers: [["To Select", true], ["To Skip", false]] },
          left: { label: "The Label", answers: [["LCorrect", true], ["LIncorrect", false]] },
          right: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] },
          extraneous: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] } },
        false # because we have extra keys
      ], [
        { center: { label: "The Label", answers: [["To Select", false], ["To Skip", false]] },
          left: [],
          right: { label: "The Label", answers: [["RCorrect", true], ["LIncorrect", false]] } },
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

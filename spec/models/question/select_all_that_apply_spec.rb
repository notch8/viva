# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::SelectAllThatApply do
  it_behaves_like "a Question"

  describe 'data serialization' do
    subject { FactoryBot.build(:question_select_all_that_apply, data:) }
    [
      [[["Green"], ["Blue", false]], false],
      [[["A", true], ["B", true], ["C", false]], true],
      [nil, false],
      ["", false],
      [[], false],
      # We have a triple and a single.
      [[["Green", true, "Yellow"], ["t"]], false],
      # We have two pairs, which should be valid.
      [[["A", true], ["B", false]], true],
      # TODO: We probably want to enforce that all questions have at least one correct answer.
      # Highlighting that for now all answers could be incorrect.
      [[["Green", false], ["Blue", false]], true]
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

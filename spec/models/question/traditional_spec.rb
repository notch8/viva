# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Traditional do
  it_behaves_like "a Question"

  describe 'data serialization' do
    subject { FactoryBot.build(:question_traditional, data:) }
    [
      [[["Green"], ["Blue", false]], false],
      [[["A", true], ["B", false], ["C", false]], true],
      # The last element for each pair must be a boolean
      [[["A", true], ["B", false], ["C", nil]], false],
      # Disallow more than one correct answer
      [[["A", true], ["B", true], ["C", false]], false],
      [nil, false],
      ["", false],
      [[], false],
      # We have a triple and a single.
      [[["Green", true, "Yellow"], ["t"]], false],
      # We have two pairs, which should be valid.
      [[["A", true], ["B", false]], true],
      [[["Green", false], ["Blue", false]], false],
      [[["Green", false], ["Blue", true]], true]
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

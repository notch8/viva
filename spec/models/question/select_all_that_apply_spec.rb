# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::SelectAllThatApply do
  it_behaves_like "a Question"

  describe 'data serialization' do
    subject { FactoryBot.build(:question_select_all_that_apply, data:) }
    [
      ["Green::t|Blue::false|Red::1|Yellow::0", [["Green", true], ["Blue", false], ["Red", true], ["Yellow", false]], true],
      ["Green|Blue::false", [["Green"], ["Blue", false]], false],
      ["A::t|B::t|C::f", [["A", true], ["B", true], ["C", false]], true],
      [nil, nil, false],
      # We only
      ["Green::t::Yellow|t", [["Green", true, "Yellow"], ["t"]], false],
      ["", [], false],
      [[["A", true], ["B", false]], [["A", true], ["B", false]], true],
      # Highlighting that for now all answers could be incorrect.
      ["Green::false|Blue::false", [["Green", false], ["Blue", false]], true]
    ].each do |given, expected, valid|
      context "when given #{given.inspect}" do
        let(:data) { given }

        its(:data) { is_expected.to eq(expected) }

        if valid
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

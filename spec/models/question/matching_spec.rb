# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Matching do
  it_behaves_like "a Question"

  describe 'data serialization' do
    subject { FactoryBot.build(:question_matching, data:) }
    [
      ["Hello::World|Wonder::Wall", [["Hello", "World"], ["Wonder", "Wall"]], true],
      ["Hello :: World | Wonder :: Wall", [["Hello", "World"], ["Wonder", "Wall"]], true],
      ["Hello :: World", [["Hello", "World"]], true],
      # When missing the right side of a pairing
      ["Hello:: |Wonder::Wall", [["Hello"], ["Wonder", "Wall"]], false],
      # When having an empty middle-part
      ["Hello| |Wonder::Wall", [["Hello"], [], ["Wonder", "Wall"]], false],
      # Given an array that is valid
      [[["Hello", "World"], ["Wonder", "Wall"]], [["Hello", "World"], ["Wonder", "Wall"]], true],
      # Given an array that has a blank value.
      [[["Hello", ""], ["Wonder", "Wall"]], [["Hello", ""], ["Wonder", "Wall"]], false]
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

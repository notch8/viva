# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Matching do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Matching") }

  describe '.import_csv_row' do
    let(:data) do
      CsvRow.new("TYPE" => "Matching",
                 "TEXT" => "Matching the proper pariings:",
                 "LEFT_1" => "Animal",
                 "RIGHT_1" => "Cat",
                 "LEFT_2" => "Plant",
                 "RIGHT_2" => "Catnip")
    end

    it "creates a matching question" do
      expect do
        described_class.import_csv_row(data)
      end.to change(described_class, :count).by(1)
      expect(described_class.last.data).to eq([["Animal", "Cat"], ["Plant", "Catnip"]])
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build(:question_matching, data:) }
    [
      [[["Hello", "World"], ["Wonder", "Wall"]], true],
      [[["Hello", "World"], ["Wonder", "Wall"]], true],
      [[["Hello", "World"]], true],
      # When missing the right side of a pairing
      [[["Hello"], ["Wonder", "Wall"]], false],
      # When having an empty middle-part
      [[["Hello"], [], ["Wonder", "Wall"]], false],
      [nil, false],
      [[], false],
      # Given an array that is valid
      [[["Hello", "World"], ["Wonder", "Wall"]], true],
      # Given an array that has a blank value.
      [[["Hello", ""], ["Wonder", "Wall"]], false]
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Matching do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Matching") }

  describe '.build_row' do
    subject { described_class.build_row(row:, questions: {}) }
    context 'with invalid data due to mismatched columns' do
      let(:row) do
        CsvRow.new("TYPE" => "Matching",
                   "TEXT" => "Matching the proper pairings:",
                   "LEVEL" => Level.names.first,
                   "LEFT_1" => "Animal",
                   "LEFT_3" => "Mineral",
                   "RIGHT_2" => "Cat, Dog",
                   "RIGHT_4" => "Weird",
                   "LEFT_5" => "Yup",
                   "RIGHT_5" => "It Matches",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }
      it "will not call the underlying question's save!" do
        expect(subject.question).not_to receive(:save!)
        # I could have one regular expression for this, but figure splitting it apart helps show with clarity.
        expect { subject.save! }.to raise_error(/Have LEFT_1, LEFT_3 columns without corresponding RIGHT_1, RIGHT_3 columns/)
        expect { subject.save! }.to raise_error(/Have RIGHT_2, RIGHT_4 columns without corresponding LEFT_2, LEFT_4 columns/)
      end
    end

    context 'with valid data' do
      let(:row) do
        CsvRow.new("TYPE" => "Matching",
                   "TEXT" => "Matching the proper pairings:",
                   "LEVEL" => Level.names.first,
                   "LEFT_1" => "Animal",
                   "RIGHT_1" => "Cat, Dog",
                   "LEFT_2" => "Plant",
                   "RIGHT_2" => "Catnip, Dogwood",
                   "LEFT_3" => "",
                   "RIGHT_3" => "",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) { is_expected.to eq([{ "answer" => "Animal", "correct" => ["Cat", "Dog"] }, { "answer" => "Plant", "correct" => ["Catnip", "Dogwood"] }]) }

      context 'when saved' do
        before { subject.save }

        its(:keyword_names) { is_expected.to match_array(["One", "Two"]) }
        its(:subject_names) { is_expected.to match_array(["Big", "Little"]) }
        its(:level) { is_expected.to eq(Level.names.first) }
      end
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build(:question_matching, data:) }
    [
      [[{ 'answer' => "Hello", 'correct' => ["World"] }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], true],
      [[{ 'answer' => "Hello", 'correct' => ["World"] }, { 'answer' => "Wonder", 'correct' => ["Wall", "Bread"] }], true],
      [[{ 'answer' => "Hello", 'correct' => "World" }], false],
      [[{ 'answer' => "Hello", 'correct' => ["World"] }], true],
      # When missing the right side of a pairing
      [[{ 'answer' => "Hello" }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], false],
      # When having an empty middle-part
      [[{ 'answer' => "Hello" }, [], { 'answer' => "Wonder", 'correct' => ["Wall"] }], false],
      [nil, false],
      [[], false],
      # Given an array that has a blank value.
      [[{ 'answer' => "Hello", 'correct' => [""] }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], false],
      # Given an array an answer is an empty array
      [[{ 'answer' => "Hello", 'correct' => [] }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], false]
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

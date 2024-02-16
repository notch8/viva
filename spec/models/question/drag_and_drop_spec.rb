# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::DragAndDrop do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Drag and Drop") }

  describe '.build_row' do
    subject { described_class.build_row(row:, questions: {}) }

    context 'when given invalid slotted data' do
      let(:row) do
        CsvRow.new("TYPE" => "Drag and Drop",
                   "TEXT" => "___1___ is comprised of ___2___",
                   "LEVEL" => Level.names.first,
                   "ANSWER_1" => "Hello World!",
                   "ANSWER_3" => "Something",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }

      it "will not call the underlying question's save!" do
        expect(subject.question).not_to receive(:save!)
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid, /CORRECT_ANSWERS column indicates that ANSWER_1, ANSWER_2/)
      end
    end

    context 'when given valid slotted data' do
      let(:row) do
        CsvRow.new("TYPE" => "Drag and Drop",
                   "TEXT" => "The ___1___ gets high on ___2___:",
                   "LEVEL" => Level.names.first,
                   "ANSWER_1" => "Cat",
                   "ANSWER_2" => "Catnip",
                   "ANSWER_3" => "Blue",
                   "ANSWER_4" => "Dog",
                   "ANSWER_5" => "",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) do
        is_expected.to eq([{ "answer" => "Cat", "correct" => 1 }, { 'answer' => "Catnip", "correct" => 2 }, { 'answer' => "Blue", 'correct' => false },
                           { 'answer' => "Dog", 'correct' => false }])
      end

      context 'when saved' do
        before { subject.save }

        its(:keyword_names) { is_expected.to match_array(["one", "two"]) }
        its(:subject_names) { is_expected.to match_array(["big", "little"]) }
        its(:level) { is_expected.to eq(Level.names.first) }
      end
    end

    context 'when given invalid drag and drop all that apply data' do
      let(:row) do
        CsvRow.new("TYPE" => "Drag and Drop",
                   "TEXT" => "The prompt is...",
                   "LEVEL" => Level.names.first,
                   "CORRECT_ANSWERS" => "2,4,6",
                   "ANSWER_1" => "Hello World!",
                   "ANSWER_3" => "Something",
                   "ANSWER_5" => "Else",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }

      it "will not call the underlying question's save!" do
        expect(subject.question).not_to receive(:save!)
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid, /CORRECT_ANSWERS column indicates that ANSWER_2, ANSWER_4, ANSWER_6/)
      end
    end

    context 'when given valid drag and drop all that apply data' do
      let(:row) do
        CsvRow.new("TYPE" => "Drag and Drop",
                   "TEXT" => "Select all of the animals:",
                   "CORRECT_ANSWERS" => "1,4",
                   "ANSWER_1" => "Cat",
                   "ANSWER_2" => "Catnip",
                   "ANSWER_3" => "Blue",
                   "ANSWER_4" => "Dog",
                   "ANSWER_5" => "",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) do
        is_expected.to(
          eq([
               { 'answer' => "Cat", 'correct' => true },
               { 'answer' => "Catnip", 'correct' => false },
               { 'answer' => "Blue", 'correct' => false },
               { 'answer' => "Dog", 'correct' => true }
             ])
        )
      end

      context 'when saved' do
        before { subject.save }

        its(:keyword_names) { is_expected.to match_array(["one", "two"]) }
        its(:subject_names) { is_expected.to match_array(["big", "little"]) }
      end
    end
  end

  describe '#slot_numbers_from_text' do
    subject { FactoryBot.build(:question_drag_and_drop, text:).slot_numbers_from_text }

    [
      ["You see a ___1___ and it is ___3___", [1, 3]],
      ["You see a ___1___ and it is ______", [1]],
      ["You see a ___ 1 ___", [1]],
      ["", []],
      [nil, []],
      # The _1_ is not a valid "slot" because it misses the format.
      ["You see a _1_ and it is __2__ with a ___3___.", [3]],
      ["You see a ___0___.", [0]]
    ].each do |given, expected|
      context "when text is #{given.inspect}" do
        let(:text) { given }

        it { is_expected.to eq(expected) }
      end
    end
  end

  describe '#sub_type' do
    subject { FactoryBot.build(:question_drag_and_drop, text: given_text).sub_type }

    context 'when text includes slots' do
      let(:given_text) { "___1___" }
      it { is_expected.to eq(described_class::SUB_TYPE_SLOTTED) }
    end

    context 'when text does not include slots' do
      let(:given_text) { "Aint no slots here" }
      it { is_expected.to eq(described_class::SUB_TYPE_ATA) }
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build(:question_drag_and_drop, data: given_data, text: given_text) }

    [
      [
        "___1___ is comprised of ___2___",
        [{ 'answer' => "Green", 'correct' => 1 }, { 'answer' => "Blue", 'correct' => 2 }, { 'answer' => "Red", 'correct' => false }],
        true
      ],
      [
        "___2___ is comprised of ___2___",
        [{ 'answer' => "Green", 'correct' => 1 }, { 'answer' => "Blue", 'correct' => 2 }],
        false # Because of the mismatch of text slots and answer slots
      ],
      [
        "___3___ is comprised of ___2___",
        [{ 'answer' => "Green", 'correct' => 1 }, { 'answer' => "Blue", 'correct' => 2 }],
        false # Because of the mismatch of text slots and answer slots
      ],
      [
        "___1___ is comprised of ___2___",
        [{ 'answer' => "Green", 'correct' => 1 }, { 'answer' => "Blue", 'correct' => 2 }, { 'answer' => "Red", 'correct' => true }],
        false # Because of the mismatch of answer slots (e.g. true and integer should not mix)
      ],
      [
        "Which is truthy?",
        [{ 'answer' => "Yes", 'correct' => true }, { 'answer' => "True", 'correct' => true }, { 'answer' => "No", 'correct' => false }],
        true # No slots needed because we have only true/false options
      ],
      [
        "Which is truthy?",
        [{ 'answer' => "Yes", 'correct' => true }, { 'answer' => "False", 'correct' => nil }],
        false # Without slots the answers must be either true or false
      ],
      [
        "Which is truthy?",
        [{ 'answer' => "Yes", 'correct' => true }, { 'answer' => "False", 'correct' => "false" }],
        false # Without slots the answers must be either true or false
      ],
      [
        "Which is truthy?",
        [{ 'answer' => "Yes", 'correct' => true }, { 'answer' => "False", 'correct' => 1 }],
        false # Without slots the answers must be either true or false
      ], [
        "Which is truthy?",
        [],
        false # Must have at least one answer
      ],
      [
        "Which is truthy?",
        nil,
        false # Must have at least one answer
      ],
      [
        "Which is truthy?",
        ["Yes", true],
        false # Must have an array of hashs for questions
      ],
      [
        "___1___",
        [{ 'answer' => "Yes", 'correct' => true }],
        false # When text has slot, answer must have slot
      ],
      [
        "___1___ and ___1___",
        [{ 'answer' => "Yes", 'correct' => 1 }],
        false # We have duplicate slots in the text but unequal candidates
      ],
      [
        "The color ___1___ is comprised of ___2___ and ___2___.",
        [{ 'answer' => "Green", 'correct' => 1 }, { 'answer' => "Blue", 'correct' => 2 }, { 'answer' => "Yellow", 'correct' => 2 }, { 'answer' => "Red", 'correct' => false }],
        true # We have duplicate slots but equal number of duplicate answers.
      ],
      [
        "___1___ and ___2___",
        [{ 'answer' => "Yes", 'correct' => 1 }, { 'answer' => "Other", 'correct' => 3 }],
        false # When text has slots there must be answers that map to each slot,
      ]
    ].each do |text, data, valid|
      context "when given text of #{text.inspect} and data of #{data.inspect}" do
        let(:given_data) { data }
        let(:given_text) { text }

        if valid
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

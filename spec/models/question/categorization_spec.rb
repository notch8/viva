# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Categorization do
  it_behaves_like "a Question"
  it_behaves_like "a Matching Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Categorization") }
  its(:choice_cardinality_is_multiple?) { is_expected.to be_truthy }

  describe '.build_row' do
    context 'for cardinality validation' do
      subject { described_class.build_row(row:, questions: {}) }

      let(:row) do
        CsvRow.new("TYPE" => "Categorization",
                   "TEXT" => "Arrange the numbers in numeric order:",
                   "LEVEL" => Level.names.first,
                   "LEFT_1" => "First",
                   "LEFT_2" => "Second",
                   "LEFT_3" => "Third",
                   "LEFT_4" => "Fourth",
                   "RIGHT_1" => "Negative Two",
                   "RIGHT_2" => "Zero",
                   "RIGHT_3" => "One",
                   "RIGHT_4" => "Three",
                   "KEYWORD" => "Math",
                   "SUBJECT" => "Big, Little")
      end
      it { is_expected.to be_valid }
      it "will call the underlying question's save!" do
        expect(subject.question).to receive(:save!).and_call_original
        expect { subject.save! }.not_to raise_error
      end
    end
  end
end

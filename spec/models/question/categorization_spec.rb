# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Categorization do
  it_behaves_like "a Question"
  it_behaves_like "a Matching Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Categorization") }

  describe '.build_row' do
    context 'for arrange answers in an order' do
      subject { described_class.build_row(row:, questions: {}) }

      let(:row) do
        CsvRow.new("TYPE" => "Categorization",
                   "TEXT" => "Arrange the numbers in numeric order:",
                   "LEVEL" => Level.names.first,
                   "CHOICE_1" => "First",
                   "CHOICE_2" => "Second",
                   "CHOICE_3" => "Third",
                   "CHOICE_4" => "Fourth",
                   "RESPONSE_1" => "Negative Two",
                   "RESPONSE_2" => "Zero",
                   "RESPONSE_3" => "One",
                   "RESPONSE_4" => "Three",
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

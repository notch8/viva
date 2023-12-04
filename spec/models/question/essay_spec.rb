# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Essay do
  it_behaves_like "a Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Essay") }

  describe '.build_row' do
    subject { described_class.build_row(row:, questions: {}) }
    context 'with invalid data due to mismatched columns' do
      let(:row) do
        CsvRow.new("TYPE" => "Matching",
                   "TEXT" => "Title of Question",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }
      it "will not call the underlying question's save!" do
        expect(subject.question).not_to receive(:save!)
        expect { subject.save! }.to raise_error(/expected one or more SECTION_ columns/)
      end
    end

    context 'with at least one SECTION_ column' do
      let(:row) do
        CsvRow.new("TYPE" => "Matching",
                   "TEXT" => "Title of Question",
                   "SECTION_1" => "* Bullet Point",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) { is_expected.to eq({ "markdown" => "* Bullet Point" }) }

      it 'will save the underlying record' do
        expect { subject.save }.to change(described_class, :count).by(1)
      end
    end
  end
end

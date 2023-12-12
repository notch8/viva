# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Matching do
  it_behaves_like "a Question", export_as_xml: true
  it_behaves_like "a Matching Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Matching") }
  its(:qti_max_value) { is_expected.to be_a(Integer) }
  its(:choice_cardinality_is_multiple?) { is_expected.to be_falsey }

  context '.build_data' do
    subject { described_class.build_row(row:, questions: {}) }
    let(:row) do
      CsvRow.new("TYPE" => described_class.type_name,
                 "TEXT" => "#{described_class.type_name} the proper pairings:",
                 "LEVEL" => Level.names.first,
                 "LEFT_1" => "Animal",
                 "RIGHT_1" => "Cat, Dog",
                 "LEFT_2" => "Plant",
                 "RIGHT_2" => "Catnip, Dogwood",
                 "KEYWORD" => "One, Two",
                 "SUBJECT" => "Big, Little")
    end

    it { is_expected.not_to be_valid }
    it { is_expected.not_to be_persisted }

    it "will raise a message" do
      expect(subject.question).not_to receive(:save!)
      # I could have one regular expression for this, but figure splitting it apart helps show with clarity.
      expect { subject.save! }.to raise_error(%r{expected columns "RIGHT_1", "RIGHT_2" to have one and only one answer})
    end
  end
end

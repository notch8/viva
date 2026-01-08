# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Scenario do
  it_behaves_like "a Question", test_type_name_to_class: false, included_in_filterable_type: false
  its(:type_label) { is_expected.to eq("Scenario") }
  its(:type_name) { is_expected.to eq("Scenario") }

  subject { described_class.new }

  its(:child_of_aggregation) { is_expected.to eq(true) }
  its(:data) { is_expected.to be_nil }

  describe '.build_row' do
    let(:user) { create(:user) }
    subject { described_class.build_row(row:, questions:, user_id: user.id) }
    let(:row) do
      CsvRow.new("TYPE" => "Scenario",
                 "TEXT" => "Something Something Scenario",
                 "PART_OF" => 1)
    end

    context 'when provided an existing PART_OF' do
      let(:questions) { { 1 => case_study } }
      let(:case_study) { FactoryBot.build(:question_stimulus_case_study_without_children) }

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
    end

    context 'when not provided a PART_OF' do
      let(:questions) { {} }
      let(:case_study) { nil }
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }
    end
  end
end

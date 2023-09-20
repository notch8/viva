# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Scenario do
  it_behaves_like "a Question", test_type_name_to_class: false, include_in_filterable_type: false
  its(:type_label) { is_expected.to eq("Scenario") }
  its(:type_name) { is_expected.to eq("Scenario") }

  subject { described_class.new }

  its(:child_of_aggregation) { is_expected.to eq(true) }
  its(:data) { is_expected.to be_nil }

  describe '.import_csv_row' do
    let(:data) do
      CsvRow.new("TYPE" => "Scenario",
                 "TEXT" => "Something Something Scenario",
                 "PART_OF" => case_study)
    end

    context 'when provided an existing PART_OF' do
      let(:case_study) { FactoryBot.build(:question_stimulus_case_study_without_children) }
      it "creates a scenario question" do
        expect { described_class.import_csv_row(data) }.to change(described_class, :count).by(1)
      end
    end

    context 'when not provided a PART_OF' do
      let(:case_study) { nil }
      it "raises an exception" do
        expect { described_class.import_csv_row(data) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end

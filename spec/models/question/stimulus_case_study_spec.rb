# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::StimulusCaseStudy do
  it_behaves_like "a Question", has_parts: true
  its(:type_label) { is_expected.to eq("Case Study") }
  its(:type_name) { is_expected.to eq("Stimulus Case Study") }

  it { is_expected.to have_many(:as_parent_question_aggregations) }
  it { is_expected.to have_many(:child_questions) }

  describe '.build_row' do
    subject { described_class.build_row(row:, questions: { 1 => FactoryBot.build(:question_stimulus_case_study) }) }

    context 'when PART_OF another question' do
      let(:row) do
        CsvRow.new("TITLE" => "Title",
                   "PART_OF" => 1,
                   "IMPORT_ID" => 2,
                   "TEXT" => "Hello World")
      end

      it { is_expected.not_to be_valid }
    end

    context 'when PART_OF another question' do
      let(:row) do
        CsvRow.new("TITLE" => "Title",
                   "IMPORT_ID" => 2,
                   "TEXT" => "Hello World")
      end

      it { is_expected.to be_valid }
    end
  end

  describe 'factories' do
    it "generates child questions" do
      expect do
        expect do
          FactoryBot.create(:question_stimulus_case_study)
        end.to change(Question::StimulusCaseStudy, :count).by(1)
      end.to change(QuestionAggregation, :count)

      # We want to verify that the factory also creates the child questions
      expect(Question.where(child_of_aggregation: true).count).to eq(QuestionAggregation.count)
    end
  end

  describe '#data' do
    subject { FactoryBot.create(:question_stimulus_case_study).data }
    it "is comprised of the child_question's metadata" do
      expect(subject).to be_a(Array)

      # All elements are Hashes
      expect(subject.all? { |d| d.is_a?(Hash) }).to eq(true)

      # Making an assumption about the factory; namely that the first element is a scenario.
      expect(subject[0].keys).to match_array(["type_label", "type_name", "text", "images"])

      # The second element is a non-scenario Question, and thus has data.
      expect(subject[1].keys).to match_array(["type_label", "type_name", "text", "data", "images"])
    end
  end
end

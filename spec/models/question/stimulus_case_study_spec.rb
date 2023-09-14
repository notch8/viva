# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::StimulusCaseStudy do
  it_behaves_like "a Question"

  it { is_expected.to have_many(:as_parent_question_aggregations) }
  it { is_expected.to have_many(:child_questions) }

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
end

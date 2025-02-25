# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::MarkdownService do
  let(:service) { described_class.new(question) }

  describe '#format' do
    subject { service.format_content }

    context 'with an essay question' do
      let(:question) do
        create(:question_essay,
          text: 'Sample essay question',
          data: { 'html' => '<p>Essay prompt</p><ul><li>Point 1</li></ul><a href="https://example.com">Link</a>' })
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Essay
          **QUESTION:** Sample essay question

          **Text:** Essay prompt
          - Point 1
          Link (https://example.com)

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with an upload question' do
      let(:question) do
        create(:question_upload,
          text: 'Sample upload question',
          data: { 'html' => '<p>Upload instructions</p><ul><li>File type: PDF</li></ul><a href="https://example.com">Guidelines</a>' })
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Upload
          **QUESTION:** Sample upload question

          **Text:** Upload instructions
          - File type: PDF
          Guidelines (https://example.com)

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a multiple choice question' do
      let(:question) do
        create(:question_traditional,
          text: 'Sample multiple choice',
          data: [
            { 'answer' => 'Option A', 'correct' => true },
            { 'answer' => 'Option B', 'correct' => false }
          ])
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Multiple Choice
          **QUESTION:** Sample multiple choice

          1) Correct: Option A
          2) Incorrect: Option B

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a select all that apply question' do
      let(:question) do
        create(:question_select_all_that_apply,
          text: 'Sample select all question',
          data: [
            { 'answer' => 'Option A', 'correct' => true },
            { 'answer' => 'Option B', 'correct' => true },
            { 'answer' => 'Option C', 'correct' => false }
          ])
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Select All That Apply
          **QUESTION:** Sample select all question

          1) Correct: Option A
          2) Correct: Option B
          3) Incorrect: Option C

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a drag and drop question' do
      let(:question) do
        create(:question_drag_and_drop,
          text: 'Sample drag and drop question',
          data: [
            { 'answer' => 'Item 1', 'correct' => true },
            { 'answer' => 'Item 2', 'correct' => false },
            { 'answer' => 'Item 3', 'correct' => true }
          ])
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Drag and Drop
          **QUESTION:** Sample drag and drop question

          1) Correct: Item 1
          2) Incorrect: Item 2
          3) Correct: Item 3

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a matching question' do
      let(:question) do
        create(:question_matching,
          text: 'Sample matching question',
          data: [
            {
              'answer' => 'Term 1',
              'correct' => ['Definition 1']
            },
            {
              'answer' => 'Term 2',
              'correct' => ['Definition 2']
            },
            {
              'answer' => 'Term 3',
              'correct' => ['Definition 3']
            }
          ])
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Matching
          **QUESTION:** Sample matching question

          1) Term 1
             Correct Match: Definition 1
          2) Term 2
             Correct Match: Definition 2
          3) Term 3
             Correct Match: Definition 3

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a categorization question' do
      let(:question) do
        create(:question_categorization,
          text: 'Sample categorization',
          data: [
            { 'answer' => 'Category 1', 'correct' => ['Item 1', 'Item 2'] },
            { 'answer' => 'Category 2', 'correct' => ['Item 3'] }
          ])
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Categorization
          **QUESTION:** Sample categorization

          **Category:** Category 1
          1) Item 1
          2) Item 2

          **Category:** Category 2
          1) Item 3

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a bow tie question' do
      let(:question) do
        create(:question_bow_tie,
          text: 'Sample bow tie question',
          data: {
            'center' => {
              'label' => 'Center Label',
              'answers' => [
                { 'answer' => 'Center Answer 1', 'correct' => true },
                { 'answer' => 'Center Answer 2', 'correct' => false }
              ]
            },
            'left' => {
              'label' => 'Left Label',
              'answers' => [
                { 'answer' => 'Left Answer 1', 'correct' => true },
                { 'answer' => 'Left Answer 2', 'correct' => false }
              ]
            },
            'right' => {
              'label' => 'Right Label',
              'answers' => [
                { 'answer' => 'Right Answer 1', 'correct' => true },
                { 'answer' => 'Right Answer 2', 'correct' => false }
              ]
            }
          })
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Bow Tie
          **QUESTION:** Sample bow tie question

          Center
          1) Correct: Center Answer 1
          2) Incorrect: Center Answer 2

          Left
          1) Correct: Left Answer 1
          2) Incorrect: Left Answer 2

          Right
          1) Correct: Right Answer 1
          2) Incorrect: Right Answer 2

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end

    context 'with a stimulus case study question' do
      let(:scenario) { create(:question_scenario, text: 'Sample scenario') }
      let(:sub_question_essay) { create(:question_essay, text: 'Sub question', data: { 'html' => '<p>Essay prompt</p>' }) }
      let(:sub_question_mc) do
        create(:question_traditional,
          text: 'Multiple choice sub question',
          data: [
            { 'answer' => 'Option A', 'correct' => true },
            { 'answer' => 'Option B', 'correct' => false }
          ])
      end
      let(:question) do
        create(:question_stimulus_case_study,
          text: 'Main question',
          child_questions: [scenario, sub_question_essay, sub_question_mc])
      end

      it 'formats the question correctly' do
        expected_output = <<~TEXT
          ## QUESTION TYPE: Stimulus Case Study
          **QUESTION:** Main question

          **Scenario:** Sample scenario

          ### Subquestion Type: Essay
          **Subquestion:** Sub question

          **Text:** Essay prompt

          ### Subquestion Type: Multiple Choice
          **Subquestion:** Multiple choice sub question

          1) Correct: Option A
          2) Incorrect: Option B

          ---

        TEXT
        expect(subject).to eq(expected_output)
      end
    end
  end
end

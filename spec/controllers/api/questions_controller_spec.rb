# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::QuestionsController, type: :controller do
  describe 'POST #create' do
    let(:essay_params) do
      {
        question: {
          type: 'Question::Essay',
          level: '2',
          text: 'What is the capital of France?',
          data: { html: '<p>What is the capital of France?</p>' }.to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['France', 'Capital Cities'],
          subjects: ['Geography']
        }
      }
    end

    let(:drag_and_drop_params) do
      {
        question: {
          type: 'Question::DragAndDrop',
          level: '3',
          text: 'Arrange the items in the correct order.',
          data: [
            { "answer" => "Option A", "correct" => true },
            { "answer" => "Option B", "correct" => false }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Ordering', 'DragDrop'],
          subjects: ['Logic']
        }
      }
    end

    let(:bow_tie_params) do
      {
        question: {
          type: 'Question::BowTie',
          level: '5',
          text: 'Lifecycle of chemicals',
          data: {
            "center" => {
              "label" => "Center Label",
              "answers" => [
                { "answer" => "Center correct answer", "correct" => true },
                { "answer" => "Center incorrect answer 1", "correct" => false },
                { "answer" => "Center incorrect answer 2", "correct" => false },
                { "answer" => "Center incorrect answer 3", "correct" => false }
              ]
            },
            "left" => {
              "label" => "Left Label",
              "answers" => [
                { "answer" => "Left Correct Answer 1", "correct" => true },
                { "answer" => "Left Correct Answer 2 with longer text to test for responsiveness", "correct" => true },
                { "answer" => "Left Incorrect Answer 1", "correct" => false },
                { "answer" => "Left Incorrect Answer 2 with longer text to test for responsiveness", "correct" => false },
                { "answer" => "Left Incorrect Answer 3", "correct" => false }
              ]
            },
            "right" => {
              "label" => "Right Label",
              "answers" => [
                { "answer" => "Right Correct Answer 1", "correct" => true },
                { "answer" => "Right Correct Answer 2", "correct" => true },
                { "answer" => "Right Incorrect Answer 1 with longer text to test for responsiveness", "correct" => false },
                { "answer" => "Right Incorrect Answer 2", "correct" => false },
                { "answer" => "Right Incorrect Answer 3", "correct" => false }
              ]
            }
          }.to_json
        }
      }
    end

    let(:matching_params) do
      {
        question: {
          type: 'Question::Matching',
          level: '1',
          text: 'Match the inhibitors with their respective drug names.',
          data: [
            { "answer" => "Selective Serotonin Reuptake Inhibitors", "correct" => ["Citalopram"] },
            { "answer" => "Serotonin-norepinephrine Reuptake Inhibitors", "correct" => ["Desvenlafaxine"] }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['SSRIs', 'SNRIs'],
          subjects: ['Pharmacology']
        }
      }
    end

    let(:categorization_params) do
      {
        question: {
          type: 'Question::Categorization',
          level: '4',
          text: 'Categorize the following items.',
          data: [
            { "answer" => "Fruits", "correct" => ["Apple", "Banana", "Cherry"] },
            { "answer" => "Vegetables", "correct" => ["Carrot", "Broccoli", "Spinach"] }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Food Groups', 'Categorization'],
          subjects: ['Nutrition']
        }
      }
    end

    let(:invalid_params) do
      { question: { text: '' } }
    end

    context 'when creating an essay question' do
      it 'creates an essay question with all parameters' do
        expect { post :create, params: essay_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('What is the capital of France?')
        expect(question.level).to eq('2')
        expect(question.data).to eq({ 'html' => '<p>What is the capital of France?</p>' })
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('france', 'capital cities')
        expect(question.subjects.map(&:name)).to contain_exactly('geography')
      end
    end

    context 'when creating a Drag and Drop question' do
      it 'creates a Drag and Drop question with all parameters' do
        expect { post :create, params: drag_and_drop_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Arrange the items in the correct order.')
        expect(question.level).to eq('3')
        expect(question.data).to eq(
          [
            { "answer" => "Option A", "correct" => true },
            { "answer" => "Option B", "correct" => false }
          ]
        )
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('ordering', 'dragdrop')
        expect(question.subjects.map(&:name)).to contain_exactly('logic')
      end
    end

    context 'when creating a Matching question' do
      it 'creates a Matching question with all parameters' do
        expect { post :create, params: matching_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Match the inhibitors with their respective drug names.')
        expect(question.level).to eq('1')
        expect(question.data).to eq(
          [
            { "answer" => "Selective Serotonin Reuptake Inhibitors", "correct" => ["Citalopram"] },
            { "answer" => "Serotonin-norepinephrine Reuptake Inhibitors", "correct" => ["Desvenlafaxine"] }
          ]
        )
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('ssris', 'snris')
        expect(question.subjects.map(&:name)).to contain_exactly('pharmacology')
      end
    end

    context 'when creating a Categorization question' do
      it 'creates a Categorization question with all parameters' do
        expect { post :create, params: categorization_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Categorize the following items.')
        expect(question.level).to eq('4')
        expect(question.data).to eq(
          [
            { "answer" => "Fruits", "correct" => ["Apple", "Banana", "Cherry"] },
            { "answer" => "Vegetables", "correct" => ["Carrot", "Broccoli", "Spinach"] }
          ]
        )
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('food groups', 'categorization')
        expect(question.subjects.map(&:name)).to contain_exactly('nutrition')
      end

      it 'does not create a Categorization question with invalid data' do
        invalid_data_params = categorization_params.deep_merge(question: { data: [].to_json })

        expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('expected to be a non-empty array.')
      end
    end

    context 'when creating a Bow Tie question' do
      context 'with valid parameters' do
        it 'creates a new Bow Tie question' do
          post :create, params: bow_tie_params
          expect { post :create, params: bow_tie_params }.to change(Question, :count).by(1)
          question = Question.last

          expect(question).not_to be_nil
          expect(question.text).to eq('Lifecycle of chemicals')
          expect(question.level).to eq('5')
          expect(question.data).to eq(
            {
              "center" => {
                "label" => "Center Label",
                "answers" => [
                  { "answer" => "Center correct answer", "correct" => true },
                  { "answer" => "Center incorrect answer 1", "correct" => false },
                  { "answer" => "Center incorrect answer 2", "correct" => false },
                  { "answer" => "Center incorrect answer 3", "correct" => false }
                ]
              },
              "left" => {
                "label" => "Left Label",
                "answers" => [
                  { "answer" => "Left Correct Answer 1", "correct" => true },
                  { "answer" => "Left Correct Answer 2 with longer text to test for responsiveness", "correct" => true },
                  { "answer" => "Left Incorrect Answer 1", "correct" => false },
                  { "answer" => "Left Incorrect Answer 2 with longer text to test for responsiveness", "correct" => false },
                  { "answer" => "Left Incorrect Answer 3", "correct" => false }
                ]
              },
              "right" => {
                "label" => "Right Label",
                "answers" => [
                  { "answer" => "Right Correct Answer 1", "correct" => true },
                  { "answer" => "Right Correct Answer 2", "correct" => true },
                  { "answer" => "Right Incorrect Answer 1 with longer text to test for responsiveness", "correct" => false },
                  { "answer" => "Right Incorrect Answer 2", "correct" => false },
                  { "answer" => "Right Incorrect Answer 3", "correct" => false }
                ]
              }
            }
          )
        end
      end
    end

    context 'when the request is invalid' do
      it 'does not create a new question' do
        expect { post :create, params: invalid_params }.not_to change(Question, :count)
      end

      it 'returns errors for invalid request' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to be_present
      end
    end
  end
end

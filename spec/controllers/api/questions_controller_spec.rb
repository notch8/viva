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
          data: { html: '<p>What is the capital of France?</p>' }.to_json, # Convert to JSON
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png'),
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
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png'),
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

    let(:invalid_params) do
      {
        question: {
          text: ''
        }
      }
    end

    context 'when creating an essay question' do
      context 'with valid parameters' do
        it 'creates a new essay question' do
          expect { post :create, params: essay_params }.to change(Question, :count).by(1)
          question = Question.last

          expect(question).not_to be_nil
          expect(question.text).to eq('What is the capital of France?')
          expect(question.level).to eq('2')
        end

        it 'associates the uploaded images with the essay question' do
          post :create, params: essay_params
          question = Question.last

          expect(question).not_to be_nil
          expect(question.images.count).to eq(2)
          expect(question.images.map(&:file).map(&:filename).map(&:to_s)).to include('test_image.png', 'test_image.png')
        end

        it 'associates the provided keywords with the essay question' do
          post :create, params: essay_params
          question = Question.last

          expect(question).not_to be_nil
          expect(question.keywords.map(&:name)).to contain_exactly('france', 'capital cities')
        end

        it 'associates the provided subjects with the essay question' do
          post :create, params: essay_params
          question = Question.last

          expect(question).not_to be_nil
          expect(question.subjects.map(&:name)).to contain_exactly('geography')
        end

        it 'returns a success message for the essay question' do
          post :create, params: essay_params

          expect(response).to have_http_status(:created)
          expect(response.parsed_body['message']).to eq('Question saved successfully!')
        end
      end
    end

    context 'when creating a Drag and Drop question' do
      context 'with valid parameters' do
        it 'creates a new Drag and Drop question' do
          expect { post :create, params: drag_and_drop_params }.to change(Question, :count).by(1)
          question = Question.last

          expect(question).not_to be_nil
          expect(question.text).to eq('Arrange the items in the correct order.')
          expect(question.level).to eq('3')
          expect(question.data).to eq(
            [
              { "answer" => "Option A", "correct" => true },
              { "answer" => "Option B", "correct" => false }
            ]
          )
        end

        it 'associates the provided keywords with the Drag and Drop question' do
          post :create, params: drag_and_drop_params
          question = Question.last

          expect(question).not_to be_nil
          expect(question.keywords.map(&:name)).to contain_exactly('ordering', 'dragdrop')
        end

        it 'associates the provided subjects with the Drag and Drop question' do
          post :create, params: drag_and_drop_params
          question = Question.last

          expect(question).not_to be_nil
          expect(question.subjects.map(&:name)).to contain_exactly('logic')
        end
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

      it 'returns a list of errors' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to be_present
      end
    end
  end
end

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

    # Essay Tests
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

    # Drag and Drop Tests
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

    # Matching Tests
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

    # Categorization Tests
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

    # Invalid General Tests
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::QuestionsController do
  describe 'POST #create' do
    let(:valid_params) do
      {
        question: {
          type: 'Question::Essay',
          level: '2',
          text: 'What is the capital of France?',
          data: { html: '<p>What is the capital of France?</p>' },
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png'),
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['France', 'Capital Cities'],
          subjects: ['Geography']
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

    context 'when the request is valid' do
      it 'creates a new question' do
        expect { post :create, params: valid_params }.to change(Question, :count).by(1)
      end

      it 'associates the level with the question' do
        post :create, params: valid_params
        question = Question.last
        expect(question.level).to eq('2')
      end

      it 'associates the uploaded images with the question' do
        post :create, params: valid_params
        question = Question.last
        expect(question.images.count).to eq(2)
      end

      it 'associates the provided keywords with the question' do
        post :create, params: valid_params
        question = Question.last
        expect(question.keywords.map(&:name)).to contain_exactly('france', 'capital cities')
      end

      it 'associates the provided subjects with the question' do
        post :create, params: valid_params
        question = Question.last
        expect(question.subjects.map(&:name)).to contain_exactly('geography')
      end

      it 'returns a success message' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(response.parsed_body['message']).to eq('Question saved successfully!')
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

    context 'when images are provided' do
      it 'attaches the images to the question' do
        post :create, params: valid_params
        question = Question.last
        expect(question.images.count).to eq(2)
        expect(question.images.map(&:file).map(&:filename).map(&:to_s)).to include('test_image.png', 'test_image.png')
      end
    end

    context 'when keywords are provided' do
      it 'creates new keywords if they do not exist' do
        expect { post :create, params: valid_params }.to change(Keyword, :count).by(2)
      end

      it 'does not duplicate existing keywords' do
        Keyword.create(name: 'france')
        expect { post :create, params: valid_params }.to change(Keyword, :count).by(1)
      end

      it 'associates existing keywords with the question' do
        existing_keyword = Keyword.create(name: 'france')
        post :create, params: valid_params
        question = Question.last
        expect(question.keywords).to include(existing_keyword)
      end
    end

    context 'when subjects are provided' do
      it 'creates new subjects if they do not exist' do
        expect { post :create, params: valid_params }.to change(Subject, :count).by(1)
      end

      it 'does not duplicate existing subjects' do
        Subject.create(name: 'geography')
        expect { post :create, params: valid_params }.to change(Subject, :count).by(0)
      end

      it 'associates existing subjects with the question' do
        existing_subject = Subject.create(name: 'geography')
        post :create, params: valid_params
        question = Question.last
        expect(question.subjects).to include(existing_subject)
      end
    end
  end
end

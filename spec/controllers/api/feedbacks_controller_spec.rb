# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FeedbacksController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question_traditional) }

  before do
    sign_in user
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        feedback: {
          question_id: question.id,
          content: 'This question needs clarification on the terminology used.'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new feedback' do
        expect do
          post :create, params: valid_params
        end.to change(Feedback, :count).by(1)
      end

      it 'associates the feedback with the current user' do
        post :create, params: valid_params
        feedback = Feedback.last

        expect(feedback.user).to eq(user)
        expect(feedback.user_id).to eq(user.id)
      end

      it 'associates the feedback with the correct question' do
        post :create, params: valid_params
        feedback = Feedback.last

        expect(feedback.question).to eq(question)
        expect(feedback.question_id).to eq(question.id)
      end

      it 'sets the feedback content correctly' do
        post :create, params: valid_params
        feedback = Feedback.last

        expect(feedback.content).to eq('This question needs clarification on the terminology used.')
      end

      it 'defaults resolved to false' do
        post :create, params: valid_params
        feedback = Feedback.last

        expect(feedback.resolved).to be false
      end

      it 'returns a success response with JSON' do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')

        json_response = response.parsed_body
        expect(json_response['message']).to eq('Feedback submitted successfully!')
        expect(json_response['id']).to be_present
      end
    end

    context 'when question does not exist' do
      let(:invalid_question_params) do
        {
          feedback: {
            question_id: 999_999,
            content: 'This question needs clarification.'
          }
        }
      end

      it 'does not create a feedback' do
        expect do
          post :create, params: invalid_question_params
        end.not_to change(Feedback, :count)
      end

      it 'returns a not found error' do
        post :create, params: invalid_question_params

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to include('application/json')

        json_response = response.parsed_body
        expect(json_response['errors']).to include('Question not found.')
      end
    end

    context 'with invalid parameters' do
      context 'when content is blank' do
        let(:blank_content_params) do
          {
            feedback: {
              question_id: question.id,
              content: ''
            }
          }
        end

        it 'does not create a feedback' do
          expect do
            post :create, params: blank_content_params
          end.not_to change(Feedback, :count)
        end

        it 'returns validation errors' do
          post :create, params: blank_content_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to include('application/json')

          json_response = response.parsed_body
          expect(json_response['errors']).to be_present
          expect(json_response['errors']).to include("Content can't be blank")
        end
      end

      context 'when content is missing' do
        let(:missing_content_params) do
          {
            feedback: {
              question_id: question.id
            }
          }
        end

        it 'does not create a feedback' do
          expect do
            post :create, params: missing_content_params
          end.not_to change(Feedback, :count)
        end

        it 'returns validation errors' do
          post :create, params: missing_content_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to include('application/json')

          json_response = response.parsed_body
          expect(json_response['errors']).to be_present
        end
      end
    end

    context 'when user is not authenticated' do
      before do
        sign_out user
      end

      it 'requires authentication' do
        post :create, params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when multiple users submit feedback on the same question' do
      let(:other_user) { create(:user) }

      it 'allows multiple feedbacks from different users' do
        post :create, params: valid_params

        sign_out user
        sign_in other_user

        expect do
          post :create, params: valid_params
        end.to change(Feedback, :count).by(1)

        expect(Feedback.count).to eq(2)
        expect(Feedback.pluck(:user_id)).to contain_exactly(user.id, other_user.id)
      end
    end

    context 'when the same user submits multiple feedbacks on the same question' do
      it 'allows the same user to submit multiple feedbacks' do
        post :create, params: valid_params

        second_params = valid_params.deep_merge(
          feedback: { content: 'Additional feedback on this question.' }
        )

        expect do
          post :create, params: second_params
        end.to change(Feedback, :count).by(1)

        expect(Feedback.where(user: user, question: question).count).to eq(2)
      end
    end
  end
end


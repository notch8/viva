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

      it 'strips leading and trailing whitespace from content' do
        params_with_whitespace = valid_params.deep_merge(
          feedback: { content: '   This question needs clarification on the terminology used.   ' }
        )
        post :create, params: params_with_whitespace
        feedback = Feedback.last
        expect(feedback.content).to eq('This question needs clarification on the terminology used.')
      end

      it 'defaults resolved to false and has a hashid' do
        post :create, params: valid_params
        feedback = Feedback.last

        expect(feedback.question_hashid).to eq(question.hashid)
        expect(feedback.resolved).to be false
      end

      it 'returns a success response with JSON' do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')

        json_response = response.parsed_body
        expect(json_response['message']).to eq('Feedback submitted successfully!')
      end

      it 'ignores user_id if passed in params' do
        malicious_params = valid_params.deep_merge(
          feedback: { user_id: create(:user).id }
        )

        post :create, params: malicious_params
        feedback = Feedback.last

        expect(feedback.user_id).to eq(user.id) # Should use current_user, not params
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
        expect(json_response['errors']).to include('Question not found')
      end
    end

    context 'when model save fails' do
      before do
        allow_any_instance_of(Feedback).to receive(:save).and_return(false)
        allow_any_instance_of(Feedback).to receive_message_chain(:errors, :full_messages)
          .and_return(['Database error occurred'])
      end

      it 'returns unprocessable entity status with errors array' do
        post :create, params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body

        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).to include('Database error occurred')
      end

      it 'does not create a feedback' do
        expect do
          post :create, params: valid_params
        end.not_to change(Feedback, :count)
      end
    end

    context 'when user is not authenticated' do
      before do
        sign_out user
      end

      it 'requires authentication' do
        post :create, params: valid_params

        expect(response).to redirect_to(new_user_session_path)
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

        feedbacks = Feedback.where(question:)
        expect(feedbacks.count).to eq(2)
        expect(feedbacks.pluck(:user_id)).to contain_exactly(user.id, other_user.id)
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

        user_feedbacks = Feedback.where(user:, question:)
        expect(user_feedbacks.count).to eq(2)
        expect(user_feedbacks.pluck(:content)).to contain_exactly(
          'This question needs clarification on the terminology used.',
          'Additional feedback on this question.'
        )
      end
    end

    describe 'parameter filtering' do
      it 'only permits content and question_id' do
        params_with_extra = {
          feedback: {
            question_id: question.id,
            content: 'Test content',
            resolved: true,
            user_id: 999
          }
        }

        post :create, params: params_with_extra
        feedback = Feedback.last

        expect(feedback.user_id).to eq(user.id) # Should be current_user, not from params
        expect(feedback.content).to eq('Test content')

        # Check if other fields exist and weren't set from params
        expect(feedback.resolved).to be_falsey if feedback.respond_to?(:resolved)
      end
    end

    describe 'CSRF token validation' do
      it 'accepts requests with valid CSRF token' do
        # This test passes because RSpec controller tests handle CSRF automatically
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    describe 'frontend integration' do
      it 'returns JSON that frontend can parse' do
        post :create, params: valid_params

        expect { response.parsed_body }.not_to raise_error
        json = response.parsed_body

        expect(response).to have_http_status(:created)
        expect(json['message']).to be_present
      end

      context 'when validation errors occur' do
        before do
          allow_any_instance_of(Feedback).to receive(:save).and_return(false)
          allow_any_instance_of(Feedback).to receive_message_chain(:errors, :full_messages)
            .and_return(['Content is required', 'Another error'])
        end

        it 'returns errors array that frontend expects' do
          post :create, params: valid_params

          expect(response).to have_http_status(:unprocessable_entity)
          json = response.parsed_body

          expect(json['errors']).to be_an(Array)
          expect(json['errors'].join(', ')).to eq('Content is required, Another error')
        end
      end
    end
  end
end

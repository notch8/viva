# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::Feedbacks", type: :request do
  describe "POST /create" do
    it 'creates a new feedback for a question' do
      user = FactoryBot.create(:user)
      question = FactoryBot.create(:question_traditional)

      sign_in user

      feedback_params = {
        feedback: {
          content: "This is a test feedback.",
          question_id: question.id,
          user_id: user.id
        }
      }

      expect do
        post api_feedbacks_path, params: feedback_params
      end.to change(Feedback, :count).by(1)

      expect(response).to be_successful
    end
  end
end

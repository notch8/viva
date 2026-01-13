# frozen_string_literal: true

class Api::FeedbacksController < ApplicationController
  def create
    question = Question.find(feedback_params[:question_id])
    @feedback = question.feedbacks.new(
      feedback_params.except(:question_id, :user_id).merge(user_id: current_user.id)
    )

    if @feedback.save
      render json: { message: 'Feedback submitted successfully!' }, status: :created
    else
      render json: { errors: @feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content, :question_id)
  end
end

# app/controllers/api/feedbacks_controller.rb
class Api::FeedbacksController < ApplicationController
  before_action :authenticate_user!

  def create
    question = find_question
    return unless question
    @feedback = build_feedback(question)

    if @feedback.save
      render json: { message: 'Feedback submitted successfully!' }, status: :created
    else
      render json: { errors: @feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_question
    Question.find(feedback_params[:question_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Question not found'] }, status: :not_found
    nil
  end

  def build_feedback(question)
    question.feedbacks.build(
      content: sanitize_content(feedback_params[:content]),
      user: current_user,
      question_hashid: question.hashid
    )
  end

  def sanitize_content(content)
    # Strip whitespace to match frontend validation
    content&.strip
  end

  def feedback_params
    params.require(:feedback).permit(:content, :question_id)
  end
end

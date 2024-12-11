class Api::QuestionsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def create
    question = Question.new(question_params)

    # Handle image uploads
    if params[:question][:images].present?
      params[:question][:images].each do |uploaded_file|
        question.images.build(file: uploaded_file)
      end
    end

    if question.save
      render json: { message: 'Question saved successfully!' }, status: :created
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def question_params
    params.require(:question).permit(:type, :text, data: [:html])
  end
end

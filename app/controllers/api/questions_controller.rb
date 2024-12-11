# frozen_string_literal: true

class Api::QuestionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    question = Question.new(question_params)

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

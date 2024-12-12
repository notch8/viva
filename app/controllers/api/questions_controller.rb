# frozen_string_literal: true

class Api::QuestionsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def create
    question = Question.new(question_params.except(:keywords, :subjects, :images))
    question.level = nil if question.level.blank?

    handle_image_uploads(question)
    handle_keywords(question)
    handle_subjects(question)

    if question.save
      render json: { message: 'Question saved successfully!' }, status: :created
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def handle_image_uploads(question)
    return if params[:question][:images].blank?
    params[:question][:images].each do |uploaded_file|
      question.images.build(file: uploaded_file)
    end
  end

  def handle_keywords(question)
    return if params[:question][:keywords].blank?
    params[:question][:keywords].each do |keyword_name|
      keyword = Keyword.find_or_initialize_by(name: keyword_name.strip.downcase)
      question.keywords << keyword unless question.keywords.include?(keyword)
    end
  end

  def handle_subjects(question)
    return if params[:question][:subjects].blank?
    params[:question][:subjects].each do |subject_name|
      subject = Subject.find_or_initialize_by(name: subject_name.strip.downcase)
      question.subjects << subject unless question.subjects.include?(subject)
    end
  end

  def question_params
    params.require(:question).permit(:type, :level, :text, { data: [:html] }, { images: [] }, { keywords: [] }, { subjects: [] })
  end
end

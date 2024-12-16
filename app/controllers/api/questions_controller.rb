# frozen_string_literal: true
class Api::QuestionsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def create
    # Parse and structure the data first
    processed_params = process_question_params(question_params)

    # Initialize the question with processed params
    question = Question.new(processed_params.except(:keywords, :subjects, :images))
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

  # Process the question parameters, normalizing and cleaning data
  def process_question_params(params)
    processed = params.to_h

    # Normalize type to the correct class
    processed[:type] = normalize_type(processed[:type])

    case processed[:type]
    when 'Question::DragAndDrop'
      processed[:data] = process_drag_and_drop_data(processed[:data])
    when 'Question::Essay'
      processed[:data] = process_essay_data(processed[:data])
    when 'Question::Matching'
      processed[:data] = process_matching_data(processed[:data])
    end

    processed
  end

  def normalize_type(type)
    type_mapping = {
      'Matching' => 'Question::Matching',
      'Drag and Drop' => 'Question::DragAndDrop',
      'Bow Tie' => 'Question::BowTie',
      'Essay' => 'Question::Essay'
    }
    type_mapping[type] || type
  end

  def process_matching_data(data)
    if data.blank?
      raise ArgumentError, "Data for Matching question is required to be a non-empty array."
    end
  
    if data.is_a?(String)
      parsed_data = JSON.parse(data) rescue []
    elsif data.is_a?(Array)
      parsed_data = data
    else
      return []
    end
  
    formatted_data = parsed_data.map do |pair|
      {
        'answer' => pair['answer'].to_s.strip,
        'correct' => Array(pair['correct']).map(&:strip)
      }
    end
  
    formatted_data.reject { |pair| pair['answer'].blank? || pair['correct'].empty? }
  end
  

  def format_matching_data(data)
    data.map do |pair|
      {
        'answer' => pair['answer'].to_s.strip,
        'correct' => Array(pair['correct']).map(&:strip)
      }
    end.reject { |pair| pair['answer'].blank? || pair['correct'].empty? }
  end

  def process_drag_and_drop_data(data)
    return nil if data.blank?

    if data.is_a?(String)
      begin
        parsed_data = JSON.parse(data)
        return parsed_data if valid_drag_and_drop_data?(parsed_data)
      rescue JSON::ParserError
        return nil
      end
    end

    data.is_a?(Array) && valid_drag_and_drop_data?(data) ? data : nil
  end

  def process_essay_data(data)
    return nil if data.blank?

    if data.is_a?(String)
      JSON.parse(data) rescue nil
    else
      data
    end
  end

  def valid_drag_and_drop_data?(data)
    return false unless data.is_a?(Array)

    data.all? do |item|
      item.is_a?(Hash) &&
        item['answer'].present? &&
        item.key?('correct') &&
        [true, false].include?(item['correct'])
    end
  end

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
    params.require(:question).permit(
      :type,
      :level,
      :text,
      :data,
      images: [],
      keywords: [],
      subjects: []
    )
  end
end

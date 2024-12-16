# frozen_string_literal: true

# Controller for managing the creation of questions in different formats (Essay, Drag and Drop, Matching).
# rubocop:disable Metrics/ClassLength
class Api::QuestionsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  ##
  # Creates a new question.
  #
  # @note Handles question creation for various types (Essay, Matching, Drag and Drop).
  # @return [JSON] Success message or error messages.
  #
  # @example Request Payload
  #   {
  #     "question": {
  #       "type": "Question::Matching",
  #       "text": "Match the items",
  #       "data": [{"answer": "A", "correct": ["B"]}],
  #       "keywords": ["example"],
  #       "subjects": ["test"]
  #     }
  #   }
  def create
    processed_params = process_question_params(question_params)

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

  ##
  # Processes and normalizes the question parameters.
  #
  # @param [ActionController::Parameters] params The raw parameters passed in the request.
  # @return [Hash] Processed parameters with normalized data.
  def process_question_params(params)
    processed = params.to_h
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

  ##
  # Maps user-friendly question types to their full class names.
  #
  # @param [String] type The type of question in user-friendly form.
  # @return [String] The full class name of the question type.
  def normalize_type(type)
    type_mapping = {
      'Matching' => 'Question::Matching',
      'Drag and Drop' => 'Question::DragAndDrop',
      'Bow Tie' => 'Question::BowTie',
      'Essay' => 'Question::Essay'
    }
    type_mapping[type] || type
  end

  ##
  # Processes data for a Matching question type.
  #
  # @param [String, Array] data The input data in JSON or Array format.
  # @raise [ArgumentError] If data is blank.
  # @return [Array<Hash>] Formatted array of matching pairs.
  def process_matching_data(data)
    raise ArgumentError, 'Data for Matching question is required to be a non-empty array.' if data.blank?

    parsed_data = parse_matching_data(data)
    clean_matching_data(parsed_data)
  end

  ##
  # Parses raw data for Matching questions.
  #
  # @param [String, Array] data The input data.
  # @return [Array<Hash>] Parsed data.
  def parse_matching_data(data)
    if data.is_a?(String)
      begin
        JSON.parse(data)
      rescue JSON::ParserError
        []
      end
    elsif data.is_a?(Array)
      data
    else
      []
    end
  end

  ##
  # Cleans up parsed Matching question data.
  #
  # @param [Array<Hash>] data The input array of pairs.
  # @return [Array<Hash>] Cleaned and valid matching pairs.
  def clean_matching_data(data)
    formatted_data = data.map do |pair|
      {
        'answer' => pair['answer'].to_s.strip,
        'correct' => Array(pair['correct']).map(&:strip)
      }
    end

    formatted_data.reject do |pair|
      pair['answer'].blank? || pair['correct'].empty?
    end
  end

  ##
  # Processes data for a Drag and Drop question type.
  #
  # @param [String, Array] data The input data in JSON or Array format.
  # @return [Array, nil] Validated and parsed data, or nil if invalid.
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

  ##
  # Processes data for an Essay question type.
  #
  # @param [String, Hash] data The input data in JSON or Hash format.
  # @return [Hash, nil] Parsed essay data or nil if invalid.
  def process_essay_data(data)
    return nil if data.blank?

    if data.is_a?(String)
      begin
        JSON.parse(data)
      rescue JSON::ParserError
        nil
      end
    else
      data
    end
  end

  ##
  # Validates Drag and Drop data.
  #
  # @param [Array] data The input data to validate.
  # @return [Boolean] Whether the data is valid.
  def valid_drag_and_drop_data?(data)
    return false unless data.is_a?(Array)

    data.all? do |item|
      item.is_a?(Hash) &&
        item['answer'].present? &&
        item.key?('correct') &&
        [true, false].include?(item['correct'])
    end
  end

  ##
  # Handles image uploads and attaches them to the question.
  #
  # @param [Question] question The question object to associate images with.
  def handle_image_uploads(question)
    return if params[:question][:images].blank?

    params[:question][:images].each do |uploaded_file|
      question.images.build(file: uploaded_file)
    end
  end

  ##
  # Handles keyword associations for a question.
  #
  # @param [Question] question The question object to associate keywords with.
  def handle_keywords(question)
    return if params[:question][:keywords].blank?

    params[:question][:keywords].each do |keyword_name|
      keyword = Keyword.find_or_initialize_by(name: keyword_name.strip.downcase)
      question.keywords << keyword unless question.keywords.include?(keyword)
    end
  end

  ##
  # Handles subject associations for a question.
  #
  # @param [Question] question The question object to associate subjects with.
  def handle_subjects(question)
    return if params[:question][:subjects].blank?

    params[:question][:subjects].each do |subject_name|
      subject = Subject.find_or_initialize_by(name: subject_name.strip.downcase)
      question.subjects << subject unless question.subjects.include?(subject)
    end
  end

  ##
  # Permits and requires the necessary question parameters.
  #
  # @return [ActionController::Parameters] The permitted parameters for a question.
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
# rubocop:enable Metrics/ClassLength

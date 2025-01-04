# frozen_string_literal: true

# Controller for managing the creation of questions in different formats (Essay, Drag and Drop, Matching, Bow Tie).

# rubocop:disable Metrics/ClassLength
class Api::QuestionsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  ##
  # Creates a new question.
  #
  # @note Handles question creation for various types (Essay, Matching, Drag and Drop, Bow Tie, etc).
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

    if processed_params[:type] == 'Question::StimulusCaseStudy'
      begin
        stimulus_case_study = process_stimulus_case_study_data(processed_params[:data], processed_params)
        render json: { message: 'Stimulus Case Study saved successfully!', id: stimulus_case_study.id }, status: :created
      rescue ArgumentError => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end
      return
    end

    # For all other question types
    question = Question.new(processed_params.except(:keywords, :subjects, :images))
    question.level = nil if question.level.blank?

    handle_image_uploads(question)
    handle_keywords(question)
    handle_subjects(question)

    if question.save
      render json: { message: 'Question saved successfully!', id: question.id }, status: :created
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ArgumentError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  ##
  # Processes and normalizes the question parameters.
  #
  # @param [ActionController::Parameters] params The raw parameters passed in the request.
  # @return [Hash] Processed parameters with normalized data.
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def process_question_params(params)
    processed = params.to_h
    processed[:type] = normalize_type(processed[:type])

    case processed[:type]
    when 'Question::Traditional'
      processed[:data] = process_multiple_choice_data(processed[:data]) if processed[:data].present?
    when 'Question::SelectAllThatApply'
      processed[:data] = process_select_all_data(processed[:data]) if processed[:data].present?
    when 'Question::Categorization'
      processed[:data] = process_categorization_data(processed[:data])
    when 'Question::DragAndDrop'
      processed[:data] = process_drag_and_drop_data(processed[:data])
    when 'Question::Essay'
      processed[:data] = process_essay_data(processed[:data])
    when 'Question::BowTie'
      processed[:data] = process_bow_tie_data(processed[:data])
    when 'Question::Matching'
      processed[:data] = process_matching_data(processed[:data])
    end

    processed
  end

  def process_stimulus_case_study_data(data, params)
    # Ensure data is parsed
    data = JSON.parse(data) if data.is_a?(String)
    raise ArgumentError, 'Stimulus Case Study data is required.' if data.blank?

    # Create Stimulus Case Study instance
    stimulus_case_study = Question::StimulusCaseStudy.new(
      text: data['text'],
      child_of_aggregation: false,
      level: params[:level]
    )

    # Handle attachments (images, keywords, subjects)
    params[:images]&.each do |uploaded_file|
      stimulus_case_study.images.build(file: uploaded_file)
    end

    params[:keywords]&.each do |keyword_name|
      keyword = Keyword.find_or_initialize_by(name: keyword_name.strip.downcase)
      stimulus_case_study.keywords << keyword unless stimulus_case_study.keywords.include?(keyword)
    end

    params[:subjects]&.each do |subject_name|
      subject = Subject.find_or_initialize_by(name: subject_name.strip.downcase)
      stimulus_case_study.subjects << subject unless stimulus_case_study.subjects.include?(subject)
    end

    # Map subquestions and validate data
    subquestions = data['subQuestions']&.map do |subquestion_data|
      type = normalize_type(subquestion_data['type'])
      raise ArgumentError, "Invalid subquestion type: #{subquestion_data['type']}" if type.blank?

      processed_data = case type
                       when 'Question::Matching'
                         process_matching_data(subquestion_data['data'])
                       when 'Question::BowTie'
                         # Initialize default Bow Tie structure if empty
                         default_bow_tie_data = {
                           'left' => { 'answers' => [] },
                           'right' => { 'answers' => [] },
                           'center' => { 'answers' => [] }
                         }
                         process_bow_tie_data(subquestion_data['data']) || default_bow_tie_data
                       else
                         subquestion_data['data']
                       end

      Question.new(
        type:,
        text: subquestion_data['text'],
        data: processed_data,
        child_of_aggregation: true
      )
    end

    stimulus_case_study.child_questions = subquestions if subquestions.present?

    raise ArgumentError, "Error saving Stimulus Case Study: #{stimulus_case_study.errors.full_messages.join(', ')}" unless stimulus_case_study.save
    stimulus_case_study
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  ##
  # Maps user-friendly question types to their full class names.
  #
  # @param [String] type The type of question in user-friendly form.
  # @return [String] The full class name of the question type.
  def normalize_type(type)
    type_mapping = {
      'Bow Tie' => 'Question::BowTie',
      'Categorization' => 'Question::Categorization',
      'Drag and Drop' => 'Question::DragAndDrop',
      'Essay' => 'Question::Essay',
      'Matching' => 'Question::Matching',
      'Multiple Choice' => 'Question::Traditional',
      'Select All That Apply' => 'Question::SelectAllThatApply',
      'Stimulus Case Study' => 'Question::StimulusCaseStudy'
    }

    type_mapping[type] || type
  end

  ##
  # Processes data for Multiple Choice questions.
  #
  # @param [String, Array<Hash>] data The input data, either a JSON string or an array of hashes.
  # @raise [ArgumentError] If the data is invalid.
  # @return [Array<Hash>] Cleaned data with answers and correctness flags.
  def process_multiple_choice_data(data)
    parsed_data = parse_answer_data(data)

    raise ArgumentError, 'Multiple Choice questions require at least one answer.' if parsed_data.blank?

    raise ArgumentError, 'Multiple Choice questions must have exactly one correct answer.' if parsed_data.count { |item| item['correct'] } != 1

    clean_answer_data(parsed_data)
  end

  ##
  # Processes data for Select All That Apply questions.
  #
  # @param [String, Array<Hash>] data The input data, either a JSON string or an array of hashes.
  # @raise [ArgumentError] If the data is invalid.
  # @return [Array<Hash>] Cleaned data with answers and correctness flags.
  def process_select_all_data(data)
    parsed_data = parse_answer_data(data)

    raise ArgumentError, 'Select All That Apply questions require at least one answer.' if parsed_data.blank?

    raise ArgumentError, 'Select All That Apply questions must have at least one correct answer.' if parsed_data.none? { |item| item['correct'] }

    clean_answer_data(parsed_data)
  end

  ##
  # Parses answer data from a JSON string or array.
  #
  # @param [String, Array] data The input data.
  # @return [Array<Hash>] Parsed data as an array of hashes.
  def parse_answer_data(data)
    if data.is_a?(String)
      begin
        JSON.parse(data)
      rescue
        []
      end
    elsif data.is_a?(Array)
      data
    else
      []
    end
  end

  ##
  # Cleans up answer data by trimming whitespace and normalizing correctness flags.
  #
  # @param [Array<Hash>] data The input data.
  # @return [Array<Hash>] Cleaned data.
  def clean_answer_data(data)
    data.map do |item|
      {
        'answer' => item['answer'].to_s.strip,
        'correct' => item['correct']
      }
    end
  end

  ##
  # Processes data for a Categorization question.
  #
  # @param [String, Array<Hash>] data The input data, either a JSON string or an array of hashes.
  # @raise [ArgumentError] If the data is blank.
  # @return [Array<Hash>] An array of cleaned category pairs with 'answer' and 'correct' fields.
  def process_categorization_data(data)
    raise ArgumentError, 'Data for Categorization question is required to be a non-empty array.' if data.blank?

    parsed_data = parse_matching_data(data)
    clean_categorization_data(parsed_data)
  end

  ##
  # Cleans the input data by trimming whitespace and ensuring 'correct' is an array.
  #
  # @param [Array<Hash>] data An array of hashes with 'answer' and 'correct' fields.
  # @return [Array<Hash>] Cleaned data with normalized 'answer' and 'correct' values.
  def clean_categorization_data(data)
    data.map do |pair|
      {
        'answer' => pair['answer'].to_s.strip,
        'correct' => Array(pair['correct']).map(&:strip)
      }
    end
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
    parsed_data.map do |pair|
      answer = pair['answer'].to_s.strip
      correct = Array(pair['correct']).map(&:to_s).map(&:strip)

      raise ArgumentError, 'Matching pairs must have both an answer and at least one correct match.' if answer.blank? || correct.empty?

      { 'answer' => answer, 'correct' => correct }
    end
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
  # Processes data for a Bow Tie question type.
  #
  # @param [String, Hash] data The input data in JSON or Hash format.
  # @return [Hash, nil] Validated and parsed data, or nil if invalid.
  def process_bow_tie_data(data)
    return nil if data.blank?

    # If data is a string, parse it
    if data.is_a?(String)
      begin
        parsed_data = JSON.parse(data)
        return parsed_data if valid_bow_tie_data?(parsed_data)
      rescue JSON::ParserError
        return nil
      end
    end

    # If data is already a hash, validate it
    return data if data.is_a?(Hash) && valid_bow_tie_data?(data)

    nil
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
  # Validates Bow Tie data.
  #
  # @param [Hash] data The input data to validate.
  # @return [Boolean] Whether the data is valid.
  def valid_bow_tie_data?(data)
    return false unless data.is_a?(Hash)

    data.key?('left') &&
      data.key?('right') &&
      data.key?('center') &&
      data['left']['answers'].is_a?(Array) &&
      data['right']['answers'].is_a?(Array) &&
      data['center']['answers'].is_a?(Array)
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

# frozen_string_literal: true

##
# This module provides common behavior between the {Question::Matching} and {Question::Categorization}.
module MatchingQuestionBehavior
  extend ActiveSupport::Concern

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    delegate :choice_cardinality_is_multiple?, to: :question_type
    ##
    # @see #validate_well_formed_row
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def extract_answers_and_data_from(row)
      # These are reused in #validate_well_formed_row
      @lefts = []
      @rights = []
      # Ensure that we have all of the candidate indices (the left and right side)
      row.headers.each do |header|
        next if header.blank?

        if header.start_with?("LEFT_")
          @lefts << header.split(/_+/).last.to_i
        elsif header.start_with?("RIGHT_")
          @rights << header.split(/_+/).last.to_i
        end
      end

      indices = (@lefts + @rights).uniq.sort

      @data = indices.each_with_object([]) do |index, array|
        # It is okay that these will possibly be nil; because our downstream validation will catch
        # them.
        answer = row["LEFT_#{index}"]
        correct = row["RIGHT_#{index}"]&.split(/\s*,\s*/)&.map(&:strip)
        next if answer.blank? && correct.blank?
        array << { "answer" => answer, "correct" => correct }
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength

    def validate_well_formed_row
      validate_matching_lefts_and_rights
      validate_uniquenss_of_correct_choice
      validate_choice_cardinality
    end

    def validate_matching_lefts_and_rights
      return if @lefts.sort == @rights.sort

      message = "mismatch of LEFT and RIGHT columns."
      left_has = @lefts - @rights
      message += " Have LEFT_#{left_has.join(', LEFT_')} columns without corresponding RIGHT_#{left_has.join(', RIGHT_')} columns." if left_has.any?
      right_has = @rights - @lefts
      message += " Have RIGHT_#{right_has.join(', RIGHT_')} columns without corresponding LEFT_#{right_has.join(', LEFT_')} columns." if right_has.any?
      errors.add(:base, message)
    end

    def validate_uniquenss_of_correct_choice
      corrects = @rights.flat_map { |index| row["RIGHT_#{index}"]&.split(/\s*,\s*/) }.compact.map(&:strip)
      corrects_no_dups = corrects.uniq
      return true if corrects_no_dups.size == corrects.size
      dups = []
      corrects_no_dups.each do |text|
        next unless corrects.count(text) > 1
        dups << text
      end
      return true if dups.none?

      errors.add(:base, %(expected "#{dups.join('", "')}" to be unique within RIGHT columns))
    end

    def validate_choice_cardinality
      return true if choice_cardinality_is_multiple?

      invalids = []
      @rights.each do |index|
        header_name = "RIGHT_#{index}"
        next if row[header_name].blank?
        next unless row[header_name].split(/\s*,\s*/).size > 1
        invalids << header_name
      end
      return true if invalids.none?

      errors.add(:base, %(expected columns "#{invalids.join('", "')}" to have one and only one answer.))
    end
  end

  included do
    # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
    # for the data to be used in the application, beyond export of data, is minimal.
    serialize :data, JSON
    validate :well_formed_serialized_data
    class_attribute :choice_cardinality_is_multiple, default: false

    class_attribute :response_cardinality_is_multiple, default: false
  end

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:base, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    if data.empty?
      errors.add(:base, "expected to be a non-empty array.")
      return false
    end

    unless data.all? do |pair|
      pair.is_a?(Hash) &&
      pair.keys.sort == ['answer', 'correct'] &&
      pair['answer'].is_a?(String) &&
      pair['answer'].present? &&
      pair['correct'].present? &&
      pair['correct'].is_a?(Array) &&
      pair['correct'].all?(&:present?)
    end
      errors.add(:base, "expected to be an array of hashes, each hash having an answer and correct, both of which are strings")
      return false
    end

    true
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  def qti_choices
    @qti_choices ||= qti_response_conditions.flat_map(&:choices)
  end

  def qti_responses
    @qti_responses ||= qti_response_conditions.flat_map(&:response)
  end

  def qti_response_conditions
    return @qti_response_conditions if defined?(@qti_response_conditions)
    build_qti_data
    @qti_response_conditions
  end

  private

  Choice = Struct.new(:ident, :text, keyword_init: true)
  Response = Choice
  ResponseCondition = Struct.new(:choices, :response, :value, keyword_init: true) do
    delegate :ident, :text, to: :response, prefix: true
  end

  ##
  # Builds the QTI data structure for matching questions, with special attention to Canvas's
  # rendering requirements for dropdown menus.
  #
  # The method generates two types of identifiers:
  # 1. Response identifiers (format: "response_1000", "response_2000", etc.)
  # 2. Choice identifiers (format: "100", "101", etc.)
  #
  # @note While the IMS QTI 1.2 spec only requires identifiers to be unique within an item scope,
  #       Canvas has additional undocumented requirements for proper dropdown rendering. Through
  #       testing, we found that:
  #       - Simple numeric identifiers work reliably
  #       - Complex hyphenated strings (e.g., item-7d58016d00d-c-0) cause dropdown rendering issues
  #       - Each choice must have a unique identifier even if the text is the same
  #
  # @see https://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bindv1p2.html Section 3.2.4.1
  #
  def build_qti_data
    @qti_response_conditions = []

    # Calculate proportional value for scoring
    value = format("%0.2f", qti_max_value.to_f / data.count)

    # Initialize choice ID tracking
    # Starting at 100 gives room for expansion while keeping IDs short
    choice_base = 100
    used_idents = Set.new

    data.each_with_index do |datum, index|
      choices = []
      Array.wrap(datum.fetch('correct')).each do |choice|
        # Ensure unique identifiers even when choice text is duplicated
        ident = choice_base.to_s
        while used_idents.include?(ident)
          choice_base += 1
          ident = choice_base.to_s
        end

        used_idents.add(ident)
        choices << Choice.new(
          ident:,
          text: choice
        )
        choice_base += 1
      end

      # Response IDs use multiples of 1000 to maintain clear separation from choice IDs
      # and to allow for future insertion of additional responses if needed
      response = Response.new(
        ident: "response_#{(index + 1) * 1000}",
        text: datum.fetch('answer')
      )

      @qti_response_conditions << ResponseCondition.new(
        value:,
        response:,
        choices:
      )
    end
  end
  # @!endgroup QTI Exporter
  ##
end

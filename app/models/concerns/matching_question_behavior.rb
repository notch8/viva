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
    ##
    # @see #validate_well_formed_row
    #
    # rubocop:disable Metrics/MethodLength
    def extract_answers_and_data_from(row)
      # These are reused in #validate_well_formed_row
      @choices = []
      @responses = []
      # Ensure that we have all of the candidate indices (the left and right side)
      row.headers.each do |header|
        next if header.blank?

        if header.start_with?("CHOICE_")
          @choices << header.split(/_+/).last.to_i
        elsif header.start_with?("RESPONSE_")
          @responses << header.split(/_+/).last.to_i
        end
      end

      indices = (@choices + @responses).uniq.sort

      @data = indices.each_with_object([]) do |index, array|
        # It is okay that these will possibly be nil; because our downstream validation will catch
        # them.
        answer = row["CHOICE_#{index}"]
        correct = row["RESPONSE_#{index}"]&.split(/\s*,\s*/)
        next if answer.blank? && correct.blank?
        array << { "answer" => answer, "correct" => correct }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def validate_well_formed_row
      return unless @choices.sort != @responses.sort
      message = "mismatch of CHOICE and RESPONSE columns."
      choice_has = @choices - @responses
      message += " Have CHOICE_#{choice_has.join(', CHOICE_')} columns without corresponding RESPONSE_#{choice_has.join(', RESPONSE_')} columns." if choice_has.any?
      response_has = @responses - @choices
      message += " Have RESPONSE_#{response_has.join(', RESPONSE_')} columns without corresponding CHOICE_#{response_has.join(', CHOICE_')} columns." if response_has.any?
      errors.add(:base, message)
    end
  end

  included do
    # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
    # for the data to be used in the application, beyond export of data, is minimal.
    serialize :data, JSON
    validate :well_formed_serialized_data
    validates :data, presence: true
  end

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:base, "expected to be an array, got #{data.class.inspect}")
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
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  def qti_choices
    return @qti_choices if defined?(@qti_choices)
    build_qti_data
    @qti_choices
  end

  def qti_responses
    return @qti_responses if defined?(@qti_responses)
    build_qti_data
    @qti_responses
  end

  def qti_response_conditions
    return @qti_response_conditions if defined?(@qti_response_conditions)
    build_qti_data
    @qti_response_conditions
  end

  private

  Choice = Struct.new(:ident, :text, keyword_init: true)
  Response = Choice
  ResponseCondition = Struct.new(:choice, :responses, :value, keyword_init: true) do
    delegate :ident, :text, to: :choice, prefix: true
  end

  def build_qti_data
    @qti_responses = []
    @qti_choices = []
    @qti_response_conditions = []

    # We're assigning proportional value to each correct answer; we're making an assumption of 2
    # decimals of precision based on provided examples.
    value = format("%0.2f", qti_max_value.to_f / data.count)
    data.each_with_index do |datum, index|
      choice = Choice.new(ident: "#{item_ident}-c-#{index}", text: datum.fetch('answer'))
      @qti_choices << choice
      # HACK: There are examples of matching questions where a choice has multiple correct
      # responses; I don't know how we're resolving that; hence the hack.
      response = Response.new(ident: "#{item_ident}-r-#{index}", text: Array.wrap(datum.fetch('correct')).first)
      @qti_responses << response
      @qti_response_conditions << ResponseCondition.new(value:, responses: [response], choice:)
    end
  end
  # @!endgroup QTI Exporter
  ##
end

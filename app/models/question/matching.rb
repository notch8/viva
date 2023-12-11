# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  self.type_name = "Matching"

  class ImportCsvRow < MatchingQuestionBehavior::ImportCsvRow
  end

  include MatchingQuestionBehavior

  ##
  # @!group QTI Exporter
  #
  # @!attribute qti_max_value [r|w]
  #   @return [Integer]
  class_attribute :qti_max_value, default: 100

  self.export_as_xml = true

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
  ResponseCondition = Struct.new(:choice, :response, :value, keyword_init: true) do
    delegate :ident, :text, to: :choice, prefix: true
    delegate :ident, :text, to: :response, prefix: true
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
      @qti_response_conditions << ResponseCondition.new(value:, response:, choice:)
    end
  end
  # @!endgroup QTI Exporter
  ##
end

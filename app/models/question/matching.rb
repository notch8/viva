# frozen_string_literal: true

##
# A matching {Question}'s data includes pairs (e.g. A goes to B, C goes to D).
#
# @example
#   question = Question::Matching.new(text: "Hello world!", data: "A::B|C::D")
#   question.data == [["A", "B"], ["C", "D]]
#   => true
#
# @see #well_formed_serialized_data
class Question::Matching < Question
  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data

  ##
  # @param input [String, Array<Array<String>>] process the data to normalize it for persistence.
  #        When given a string assume it is a CSV cell and coerce and parse.  Otherwise, use the
  #        given input directly.  See spec/models/question/matching.rb for more details.
  def data=(input)
    if input.is_a?(String)
      # Assuming a CSV.  As we expand this work, we may need to sniff if this is XML.
      input = input.split(%r{\s*\|\s*}).map { |pair| pair.strip.split("::").map(&:strip) }
      super(input)
    else
      super
    end
  end

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? { |datum| datum.is_a?(Array) && datum.size == 2 && datum.all? { |d| d.is_a?(String) && d.present? } }
      errors.add(:data, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    true
  end
end

# frozen_string_literal: true

##
# The "Select All That Apply" question has one or more possible correct answers.  This is quite
# similar to the {Question::Traditional}; as evidenced by the duplication of code in
# {Question::SelectAllThatApply::ImportCsvRow#extract_answers_and_data_from}.  But I'd rather have
# duplication than more complicated inheritance.
class Question::SelectAllThatApply < Question
  self.type_name = "Select All That Apply"

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::SelectAllThatApply}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    def extract_answers_and_data_from(row)
      @answers = row['ANSWERS']&.split(',')&.map(&:to_i)
      @answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
      @data = answer_columns.each_with_object([]) do |col, array|
        index = col.split(/_+/).last.to_i
        next if row[col].blank? && !answers.include?(index)
        array << { 'answer' => row[col], 'correct' => answers.include?(index) }
      end
    end

    def validate_well_formed_row
      answers_as_column_names = answers.map { |a| "ANSWER_#{a}" }
      intersect = (answers_as_column_names & answer_columns)
      if intersect != answers_as_column_names
        message = "ANSWERS column indicates that #{answers_as_column_names.join(', ')} " \
                  "columns should be the correct answer, but there's a mismatch with the provided ANSWER_ columns."
        errors.add(:data, message)
      end

      correct_answers = data.select { |pair| pair['correct'] == true }
      return unless correct_answers.count.zero?
      errors.add(:data, "expected at least one correct answer, but no correct answers were specified.")
      false
    end
  end

  def self.build_row(row)
    ImportCsvRow.new(question_type: self, row:)
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  ##
  # Verify that the resulting data attribute is an array with each element being an array of a
  # string and boolean.
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Layout/LineLength
  # rubocop:disable Metrics/MethodLength
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:data, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? do |pair|
      pair.is_a?(Hash) &&
      pair.keys.sort == ["answer", "correct"] &&
      pair['answer'].present? && pair['answer'].is_a?(String) &&
      pair['answer'].present? && (pair['correct'].is_a?(TrueClass) || pair['correct'].is_a?(FalseClass))
    end
      errors.add(:data, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    # The shape of the data is correct now validate exact number of correct answers.
    correct_answers = data.select { |pair| pair['correct'] == true }

    if correct_answers.count.zero?
      errors.add(:data, "expected one correct answer, but no correct answers were specified.")
      return false
    end

    true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Layout/LineLength
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  ##
  # @!group QTI Exporter

  self.qti_xml_template_filename = 'traditional.qti.xml.erb'

  ##
  # @return [String]
  def response_cardinality
    "multiple"
  end

  ##
  # @return [Array<Integer>]
  def correct_response_identifiers
    returning_value = []
    data.each_with_index do |datum, index|
      returning_value << index if datum.fetch("correct") == true
    end
    returning_value
  end

  ##
  # @return [Integer]
  def minimum_choices
    1
  end

  ##
  # @return [Integer]
  def maximum_choices
    data.size
  end

  ##
  # @return [Array<Integer, String>]
  # @yieldparam choice_identifier [Integer]
  # @yieldparam label [String]
  def with_each_choice_identifier_and_label
    returning = []
    data.each_with_index do |datum, index|
      returning << [index, datum.fetch("answer")]
      yield index, datum.fetch("answer") if block_given?
    end
    returning
  end
  # @!endgroup QTI Exporter
  ##
end

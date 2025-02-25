# frozen_string_literal: true

##
# The "Select All That Apply" question has one or more possible correct answers.  This is quite
# similar to the {Question::Traditional}; as evidenced by the duplication of code in
# {Question::SelectAllThatApply::ImportCsvRow#extract_answers_and_data_from}.  But I'd rather have
# duplication than more complicated inheritance.
class Question::SelectAllThatApply < Question
  self.type_name = "Select All That Apply"
  self.model_exporter = 'traditional_type'

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::SelectAllThatApply}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    attr_reader :answers, :answer_columns

    def extract_answers_and_data_from(row)
      @answers = row['CORRECT_ANSWERS']
                 &.split(',')
                 &.map(&:to_i) || []
      @answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
      @data = answer_columns.each_with_object([]) do |col, array|
        index = col.split(/_+/).last.to_i
        next if row[col].blank? && answers.exclude?(index)
        array << { 'answer' => row[col], 'correct' => answers.include?(index) }
      end
    end

    def validate_well_formed_row
      errors.add(:base, "expected CORRECT_ANSWERS column") unless row['CORRECT_ANSWERS']&.strip&.present?

      answers_as_column_names = answers.map { |a| "ANSWER_#{a}" }
      intersect = (answers_as_column_names & answer_columns)
      if intersect != answers_as_column_names
        message = "CORRECT_ANSWERS column indicates that #{answers_as_column_names.join(', ')} " \
                  "columns should be the correct answer, but there's a mismatch with the provided ANSWER_ columns."
        errors.add(:base, message)
      end

      correct_answers = data.select { |pair| pair['correct'] == true }
      return unless correct_answers.count.zero?
      errors.add(:base, "expected at least one correct answer, but no correct answers were specified.")
      false
    end
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
      errors.add(:base, "expected to be an array, got #{data.class.inspect}")
      return false
    end

    unless data.all? do |pair|
      pair.is_a?(Hash) &&
      pair.keys.sort == ["answer", "correct"] &&
      pair['answer'].present? && pair['answer'].is_a?(String) &&
      pair['answer'].present? && (pair['correct'].is_a?(TrueClass) || pair['correct'].is_a?(FalseClass))
    end
      errors.add(:base, "expected to be an array of arrays, each sub-array having two elements, both of which are strings")
      return false
    end

    # The shape of the data is correct now validate exact number of correct answers.
    correct_answers = data.select { |pair| pair['correct'] == true }

    if correct_answers.count.zero?
      errors.add(:base, "expected one correct answer, but no correct answers were specified.")
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
  self.export_as_xml = true

  ##
  # @yieldparam index [Integer]
  # @yieldparam label [String] label for the choice
  # @yieldparam correctness [Boolean] true when correct answer; false when not
  # @return [Array<Integer, String, Boolean>]
  def with_each_choice_index_label_and_correctness
    returning_value = []
    data.each_with_index do |datum, index|
      element = [index, datum.fetch('answer'), datum.fetch('correct')]
      returning_value << element
      yield(*element) if block_given?
    end
    returning_value
  end
  # @!endgroup QTI Exporter
  ##
end

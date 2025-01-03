# frozen_string_literal: true

##
# One question, many candidate answers, but only one is correct.
class Question::Traditional < Question
  ##
  # Prior to Issue #261, this was labeled "Traditional".  In the database, we
  # maintain the "type" value of Traditional; as that is how we handle Single
  # Table Inheritance (STI).
  #
  # @see https://github.com/notch8/viva/issues/261
  self.type_name = "Multiple Choice"

  ##
  # Represents the mapping process of a CSV Row to the underlying {Question::Traditional}.
  #
  # The primary purpose of this class is to convey meaningful error messages for invalid CSV
  # structures.
  #
  # @see {#validate_well_formed_row}
  class ImportCsvRow < Question::ImportCsvRow
    attr_reader :answers, :answer_columns

    def extract_answers_and_data_from(row)
      # Specific to the subclass
      @answers = row['CORRECT_ANSWERS']
                 &.split(/\s*,\s*/)
                 &.map(&:to_i) ||
                 []
      @answer_columns = row.headers.select { |header| header.present? && header.start_with?("ANSWER_") }
      @data = answer_columns.each_with_object([]) do |col, array|
        index = col.split(/_+/).last.to_i
        next if row[col].blank? && answers.exclude?(index)
        array << { "answer" => row[col], "correct" => answers.include?(index) }
      end
    end

    # rubocop:disable Metrics/AbcSize
    def validate_well_formed_row
      errors.add(:base, "expected CORRECT_ANSWERS column") unless row['CORRECT_ANSWERS']&.strip&.present?

      if answers.size == 1
        if answer_columns.exclude?("ANSWER_#{answers.first}")
          errors.add(:base, "CORRECT_ANSWERS column indicates that ANSWER_#{answers.first} column should be the correct answer, but there is no ANSWER_#{answers.first}")
        end
      else
        errors.add(:base, "expected CORRECT_ANSWERS cell to have one correct answer.  The following columns are marked as correct answers: #{answers.map { |a| "ANSWER_#{a}" }.join(',')}")
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  # NOTE: We're not storing this in a JSONB data type, but instead favoring a text field.  The need
  # for the data to be used in the application, beyond export of data, is minimal.
  #
  # Because we coerce the data to JSON, the keys come back stringified.
  serialize :data, JSON
  validate :well_formed_serialized_data
  validates :data, presence: true

  ##
  # Verify that the resulting data attribute is an array with each element being an array of two
  # strings.
  #
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def well_formed_serialized_data
    unless data.is_a?(Array)
      errors.add(:base, "expected to be a Array, got #{data.class.inspect}")
      return false
    end

    unless data.all? { |pair| pair.is_a?(Hash) && pair.keys.sort == ['answer', 'correct'] && pair['answer'].is_a?(String) && (pair['correct'].is_a?(TrueClass) || pair['correct'].is_a?(FalseClass)) }
      errors.add(:base, "expected to be an array of hashes, each hash an answer and correct element, the answer being a string and the correct being a boolean")
      return false
    end

    # The shape of the data is correct now validate exact number of correct answers.
    correct_answers = data.select { |pair| pair['correct'] == true }

    if correct_answers.count.zero?
      errors.add(:base, "expected one correct answer, but no correct answers were specified.")
      return false
    elsif correct_answers.count > 1
      errors.add(:base, "expected only one correct answer, but instead have #{correct_answers.count} correct answers.")
      return false
    end

    true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  ##
  # @!group QTI Exporter
  self.export_as_xml = true

  ##
  # @return [Integer]
  def correct_response_index
    index = nil
    data.each_with_index do |datum, i|
      next unless datum.fetch('correct')
      index = i
      break
    end
    index
  end

  ##
  # @return [Array<Integer, String>]
  # @yieldparam index [Integer]
  # @yieldparam label [String]
  def with_each_choice_index_and_label
    returning = []
    data.each_with_index do |datum, index|
      element = [index, datum.fetch("answer")]
      returning << element
      yield(*element) if block_given?
    end
    returning
  end
  # @!endgroup QTI Exporter
  ##
end
